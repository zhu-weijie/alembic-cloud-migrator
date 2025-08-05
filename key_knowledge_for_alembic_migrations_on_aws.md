### Key Knowledge for Alembic Migrations on AWS

#### 1. The Entrypoint Script is Your Foundation

The `entrypoint.sh` script is the heart of the startup process. A small error here can be very hard to debug.

*   **Exit on Error:** Always start your script with `set -e`. This ensures that if any command fails (like the Alembic migration), the script will immediately stop, and the container will be marked as failed. This prevents a broken application from ever starting.
*   **The `exec "$@"` Pattern is Crucial:** The script must end with `exec "$@"`. This line replaces the script's process with the command specified in the Dockerfile's `CMD` instruction (e.g., `uvicorn`). Without this, the script would finish, and the container would successfully exit, which is not what you want for a long-running service.
*   **Provide Startup Feedback:** Use `echo` statements before and after the migration command (e.g., `echo "--- Running migrations ---"`). When debugging, these are often the only logs you'll get, telling you how far the script got before it failed.

#### 2. The Dockerfile Must Differentiate `ENTRYPOINT` and `CMD`

This was the solution to one of our most difficult "no logs" errors.

*   **`ENTRYPOINT` defines *how* to start:** It specifies the executable that will always run first. In our case, this is the `entrypoint.sh` script.
*   **`CMD` defines *what* to run:** It provides the default arguments to the `ENTRYPOINT`. In our case, this is the `uvicorn` command. `CMD` is the part that gets passed to the `"$@"` in the entrypoint script.
*   **Fix Line Endings During Build:** Your local text editor might use Windows-style line endings (`\r\n`), which will break the script in a Linux container. The most robust solution is to add `dos2unix` to your `Dockerfile` to automatically fix the line endings during the build process. This makes the build independent of your local environment.

    ```Dockerfile
    # Install the tool
    RUN apt-get update && apt-get install -y dos2unix && rm -rf /var/lib/apt/lists/*
    
    # Fix the script after copying it into the image
    COPY entrypoint.sh .
    RUN dos2unix entrypoint.sh
    ```

#### 3. Isolate Configuration and Handle Password Escaping

*   **Load Config from Environment:** Never hard-code database URLs. Always load them from environment variables injected by the ECS task definition (which in turn gets them from AWS Secrets Manager). The `pydantic-settings` library is excellent for this.
*   **The "Double Percent" (`%%`) Gotcha:** This was our final application bug.
    *   When passing a database URL to **Alembic's configuration file** (`config.set_main_option`), you **must** escape any `%` characters in the password by replacing them with `%%`.
    *   When passing a database URL directly to **SQLAlchemy's `create_engine`**, you **must NOT** escape the `%` characters.
    *   This means your `alembic/env.py` and your `app/database.py` files will construct the database URL slightly differently.

#### 4. The CI/CD IAM Role Needs Specific, Non-Obvious Permissions

A minimal IAM policy for a GitHub Actions deployment pipeline requires more than just basic ECR and ECS access.

*   **`ecr:GetAuthorizationToken` Requires `Resource: "*"`:** This permission cannot be locked down to a specific repository ARN.
*   **`iam:PassRole` is Mandatory:** The pipeline's role needs permission to "pass" the ECS Task Execution Role to the new tasks it creates. The resource for this permission must be the ARN of the role being passed.
*   **`ecs:DescribeServices` is Required for Stability Checks:** If you use `wait-for-service-stability: true` in your deploy action, the pipeline role needs this permission to check the status of the deployment.

#### 5. A Reliable and Simple Network Architecture

While VPC Endpoints are powerful, they add complexity. For many projects, a simpler design is more reliable.

*   **Run ECS Tasks in a Public Subnet:** This gives the task a public IP and a direct route to the internet via the Internet Gateway. This is the easiest way to ensure it can pull images from ECR and fetch secrets from Secrets Manager.
*   **Keep the RDS Database in a Private Subnet:** The database should never be directly accessible from the internet.
*   **Use Security Groups as Your Firewall:**
    *   The **ECS Service Security Group** should allow *inbound* traffic from the internet on the application port (e.g., 80/443).
    *   The **Database Security Group** should allow *inbound* traffic on the database port (5432) **only** from the ECS Service Security Group.

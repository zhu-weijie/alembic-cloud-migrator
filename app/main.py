from fastapi import FastAPI

app = FastAPI(title="Alembic Cloud Migrator")


@app.get("/")
def read_root():
    return {"message": "Hello World"}

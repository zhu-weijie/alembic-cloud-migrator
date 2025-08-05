from fastapi import Depends, FastAPI
from sqlalchemy.orm import Session

from . import models, schemas
from .database import SessionLocal

# This is not strictly needed for this test, but it's good practice
# to ensure tables are created when the app starts (Alembic handles this for us).
# models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Alembic Cloud Migrator")


# Dependency to get a DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.get("/")
def read_root():
    return {"message": "Hello World"}


# The new endpoint to test the database connection
@app.get("/items/", response_model=list[schemas.Item])
def read_items(db: Session = Depends(get_db)):
    items = db.query(models.Item).all()
    return items

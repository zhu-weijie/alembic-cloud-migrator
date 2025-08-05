# app/database.py
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.config import settings

# Construct the database URL, escaping the password for safety
database_url = (
    f"postgresql://{settings.POSTGRES_USER}:"
    f"{settings.POSTGRES_PASSWORD.replace('%', '%%')}@"
    f"{settings.POSTGRES_SERVER}/{settings.POSTGRES_DB}"
)

engine = create_engine(database_url)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

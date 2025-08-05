# app/schemas.py
from pydantic import BaseModel


class Item(BaseModel):
    id: int
    name: str | None = None

    class Config:
        orm_mode = True

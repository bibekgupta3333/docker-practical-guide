from fastapi import FastAPI
from pydantic import BaseModel
import uvicorn

app = FastAPI(title="Docker Tutorial API")


class Item(BaseModel):
    name: str
    description: str = None
    price: float
    tax: float = None


@app.get("/")
def read_root():
    return {"message": "Hello from FastAPI in Docker!"}


@app.get("/items/{item_id}")
def read_item(item_id: int):
    return {"item_id": item_id, "message": "This is item " + str(item_id)}


@app.post("/items/")
def create_item(item: Item):
    return {"item": item.dict(), "message": "Item created successfully"}


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)

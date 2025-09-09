from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
from google.cloud import firestore

db = firestore.Client()
router = APIRouter()

class WardrobeCategory(BaseModel):
    name: str
    image_url: str

@router.post("/wardrobe", status_code=201)
async def add_wardrobe_category(category: WardrobeCategory):
    try:
        doc_ref = db.collection("wardrobe").document(category.name)
        doc_ref.set(category.dict())
        return {"message": "Category added successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/wardrobe", response_model=List[WardrobeCategory])
async def get_wardrobe_categories():
    try:
        categories_ref = db.collection("wardrobe")
        docs = categories_ref.stream()
        return [WardrobeCategory(**doc.to_dict()) for doc in docs]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/wardrobe/{category_name}")
async def delete_wardrobe_category(category_name: str):
    try:
        doc_ref = db.collection("wardrobe").document(category_name)
        doc = doc_ref.get()
        if not doc.exists:
            raise HTTPException(status_code=404, detail="Category not found")
        doc_ref.delete()
        return {"message": f"Category '{category_name}' deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

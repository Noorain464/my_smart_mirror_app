from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
from google.cloud import firestore

db = firestore.Client()
router = APIRouter()

class ClothingItem(BaseModel):
    id: str
    image_url: str

@router.post("/wardrobe/{category_name}", status_code=201)
async def add_clothing_item(category_name: str, item: ClothingItem):
    try:
        clothing_ref = db.collection("wardrobe").document(category_name).collection("clothing_items")
        clothing_ref.add({
            "id": item.id,
            "image_url": item.image_url,
            "category": category_name,
        })
        return {"message": f"Item added to {category_name} category"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/wardrobe/{category_name}", response_model=List[ClothingItem])
async def get_items_by_category(category_name: str):
    try:
        items_ref = db.collection("wardrobe").document(category_name).collection("clothing_items")
        docs = items_ref.stream()
        return [ClothingItem(id=doc.id,image_url=doc.to_dict().get("image_url", ""),) for doc in docs]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/wardrobe/{category_name}/{item_id}", status_code=204)
async def delete_wardrobe_item(category_name: str, item_id: str):
    try:
        clothing_ref = db.collection("wardrobe").document(category_name).collection("clothing_items").document(item_id)
        if not clothing_ref.get().exists:
            raise HTTPException(status_code=404, detail="Item not found")
        clothing_ref.delete()
        return
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List
from google.cloud import firestore

db = firestore.Client()
router = APIRouter()

class WardrobeItem(BaseModel):
    id: str
    name: str
    image_url: str

@router.post("/{category_name}", status_code=201)
async def add_wardrobe_item(category_name: str, item: WardrobeItem):
    try:
        doc_ref = db.collection("wardrobe_items").document(item.id)
        doc_ref.set({
            "id": item.id,
            "name": item.name,
            "image_url": item.image_url,
            "category": category_name
        })
        return {"message": f"Item added to {category_name} category"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{category_name}", response_model=List[WardrobeItem])
async def get_items_by_category(category_name: str):
    try:
        items_ref = db.collection("wardrobe_items").where("category", "==", category_name)
        docs = items_ref.stream()
        return [WardrobeItem(id=doc.id, **doc.to_dict()) for doc in docs]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/{category_name}/{item_id}", status_code=204)
async def delete_wardrobe_item(category_name: str, item_id: str):
    try:
        doc_ref = db.collection("wardrobe_items").document(item_id)
        if not doc_ref.get().exists:
            raise HTTPException(status_code=404, detail="Item not found")
        doc_ref.delete()
        return
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

from dotenv import load_dotenv
load_dotenv()
from wadrobe import category_routes, item_routes
from fastapi import FastAPI
from google.cloud import firestore
# Initialize Firestore client
# Assumes GOOGLE_APPLICATION_CREDENTIALS env var is set to the path of the service account JSON key
db = firestore.Client()
print("Firestore client initialized")
app = FastAPI()
app.include_router(category_routes.router)
app.include_router(item_routes.router)

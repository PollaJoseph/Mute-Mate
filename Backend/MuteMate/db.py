from pymongo import MongoClient
from decouple import config

MONGO_URI = config("MONGO_URI", default="mongodb://localhost:27017/")
DB_NAME = config("DB_NAME", default="mutemate_db")

client = MongoClient(MONGO_URI)
db = client[DB_NAME]

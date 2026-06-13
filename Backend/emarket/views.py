from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny
from MuteMate.db import db
import uuid
from datetime import datetime

def format_product(p):
    return {
        "Id": p.get("prod_id"),
        "Name": p.get("name"),
        "Description": p.get("description"),
        "Price": p.get("price"),
        "Rating": p.get("rating"),
        "Colors": p.get("colors", []),
        "Category": p.get("category"),
        "FeatureMap": p.get("feature_map", {})
    }

class GetProductsView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        category = request.GET.get('category', None)
        
        if category:
            products_cursor = db.products.find({"category": {"$regex": f"^{category}$", "$options": "i"}})
            products_data = [format_product(p) for p in products_cursor]
            return Response({"Status": 200, "Data": products_data}, status=status.HTTP_200_OK)
        else:
            products_cursor = db.products.find()
            grouped_data = {}
            for p in products_cursor:
                cat = p.get("category", "uncategorized")
                if cat not in grouped_data:
                    grouped_data[cat] = []
                grouped_data[cat].append(format_product(p))
                
            return Response({"Status": 200, "Data": grouped_data}, status=status.HTTP_200_OK)

class AddProductView(APIView):
    permission_classes = [AllowAny]
    
    def post(self, request):
        data = request.data
        
        prod_id = str(uuid.uuid4())
        product_data = {
            "prod_id": prod_id,
            "name": data.get("Name"),
            "description": data.get("Description", ""),
            "price": float(data.get("Price", 0.0)),
            "rating": float(data.get("Rating", 0.0)),
            "colors": data.get("Colors", []),
            "category": data.get("Category", "uncategorized").lower(),
            "feature_map": data.get("FeatureMap", {}),
            "created_at": datetime.now(),
            "updated_at": datetime.now()
        }
        
        db.products.insert_one(product_data)
        
        return Response({
            "Status": 201, 
            "Message": "Product created successfully",
            "ProductId": prod_id
        }, status=status.HTTP_201_CREATED)

class EditProductView(APIView):
    permission_classes = [AllowAny]
    
    def put(self, request, prod_id):
        data = request.data
        
        update_fields = {"updated_at": datetime.now()}
        
        if "Name" in data: update_fields["name"] = data["Name"]
        if "Description" in data: update_fields["description"] = data["Description"]
        if "Price" in data: update_fields["price"] = float(data["Price"])
        if "Rating" in data: update_fields["rating"] = float(data["Rating"])
        if "Colors" in data: update_fields["colors"] = data["Colors"]
        if "Category" in data: update_fields["category"] = data["Category"].lower()
        if "FeatureMap" in data: update_fields["feature_map"] = data["FeatureMap"]
        
        result = db.products.update_one(
            {"prod_id": prod_id},
            {"$set": update_fields}
        )
        
        if result.matched_count == 0:
            return Response({"Error": "Product not found", "Status": 404}, status=status.HTTP_404_NOT_FOUND)
            
        return Response({"Status": 200, "Message": "Product updated successfully"}, status=status.HTTP_200_OK)

class DeleteProductView(APIView):
    permission_classes = [AllowAny]
    
    def delete(self, request, prod_id):
        result = db.products.delete_one({"prod_id": prod_id})
        
        if result.deleted_count == 0:
            return Response({"Error": "Product not found", "Status": 404}, status=status.HTTP_404_NOT_FOUND)
            
        return Response({"Status": 200, "Message": "Product deleted successfully"}, status=status.HTTP_200_OK)

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from MuteMate.db import db

def format_product(p):
    return {
        "Id": p.get("prod_id"),
        "Name": p.get("name"),
        "Description": p.get("description"),
        "Image": p.get("image", {}),
        "Price": p.get("price"),
        "Rating": p.get("rating"),
        "Category": p.get("category"),
        "FeatureMap": p.get("feature_map", {})
    }

product_schema = openapi.Schema(
    type=openapi.TYPE_OBJECT,
    properties={
        'Id': openapi.Schema(type=openapi.TYPE_STRING),
        'Name': openapi.Schema(type=openapi.TYPE_STRING),
        'Description': openapi.Schema(type=openapi.TYPE_STRING),
        'Image': openapi.Schema(
            type=openapi.TYPE_OBJECT, 
            additional_properties=openapi.Schema(type=openapi.TYPE_STRING),
            description="Map of color hex codes to image paths"
        ),
        'Price': openapi.Schema(type=openapi.TYPE_NUMBER),
        'Rating': openapi.Schema(type=openapi.TYPE_NUMBER),
        'Category': openapi.Schema(type=openapi.TYPE_STRING),
        'FeatureMap': openapi.Schema(type=openapi.TYPE_OBJECT),
    }
)

class GetProductsView(APIView):
    permission_classes = [AllowAny]

    @swagger_auto_schema(
        operation_id="GetProducts",
        operation_summary="Retrieve products catalog",
        operation_description="""
        Retrieves the product catalog. 
        
        * If category is specified, returns a flat array of products for that category.
        * If category is omitted, returns a dictionary grouped by category.
        """,
        tags=['Products'],
        manual_parameters=[
            openapi.Parameter(
                'category',
                openapi.IN_QUERY,
                description="Optional. Filter products by category (e.g., 'device' or 'supplies'). If omitted, returns all products grouped by category.",
                type=openapi.TYPE_STRING,
                required=False
            )
        ],
        responses={
            200: openapi.Response(
                description='Products retrieved successfully',
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'Status': openapi.Schema(type=openapi.TYPE_INTEGER, default=200),
                        'Data': openapi.Schema(
                            type=openapi.TYPE_OBJECT,
                            description="If ?category is provided, this will be an Array of products. If omitted, it will be a JSON Object where keys are categories and values are arrays of products.",
                            additional_properties=openapi.Schema(
                                type=openapi.TYPE_ARRAY,
                                items=product_schema
                            )
                        )
                    }
                )
            )
        }
    )
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



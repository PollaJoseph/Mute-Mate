from django.urls import path
from .views import GetProductsView, AddProductView, EditProductView, DeleteProductView

app_name = 'emarket'

urlpatterns = [
    path('Products/', GetProductsView.as_view(), name='products'),
    path('AddProduct/', AddProductView.as_view(), name='add-product'),
    path('EditProduct/<str:prod_id>/', EditProductView.as_view(), name='edit-product'),
    path('DeleteProduct/<str:prod_id>/', DeleteProductView.as_view(), name='delete-product'),
]

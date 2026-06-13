from django.urls import path
from .views import GetProductsView

app_name = 'emarket'

urlpatterns = [
    path('Products/', GetProductsView.as_view(), name='products'),
]

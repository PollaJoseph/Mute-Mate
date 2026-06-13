from django.contrib import admin
from unfold.admin import ModelAdmin
from .models import Product


@admin.register(Product)
class ProductAdmin(ModelAdmin):
    list_display = ('name', 'category', 'price', 'rating', 'prod_id', 'created_at')
    list_filter = ('category',)
    search_fields = ('name', 'description', 'prod_id')
    readonly_fields = ('prod_id', 'created_at', 'updated_at')
    ordering = ('-created_at',)
    fieldsets = (
        ('Basic Info', {
            'fields': ('prod_id', 'name', 'description', 'category')
        }),
        ('Pricing & Rating', {
            'fields': ('price', 'rating')
        }),
        ('Media & Features', {
            'fields': ('image', 'feature_map'),
            'description': (
                'image: map of color hex codes → image paths. '
                'feature_map: JSON object for additional product features.'
            )
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at')
        }),
    )

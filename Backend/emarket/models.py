from django.db import models
from django_mongodb_backend.fields import ObjectIdAutoField


class Product(models.Model):
    """
    Represents a product in the Mute-Mate eMarket catalog.
    Maps to the 'products' collection in MongoDB.
    The prod_id field is used by the API views for lookups (legacy UUID field).
    """
    id = ObjectIdAutoField(primary_key=True)
    prod_id = models.CharField(
        max_length=100, unique=True, blank=True,
        help_text="Legacy UUID identifier used by the API views"
    )
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True, default="")
    # Map of color hex codes to image paths e.g. {"#FF0000": "/media/red.png"}
    image = models.JSONField(
        default=dict, blank=True,
        help_text='Map of color hex codes to image paths e.g. {"#FF0000": "/media/red.png"}'
    )
    price = models.FloatField(default=0.0)
    rating = models.FloatField(default=0.0)

    CATEGORY_CHOICES = [
        ('device', 'Device'),
        ('supplies', 'Supplies'),
        ('uncategorized', 'Uncategorized'),
    ]
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES, default='uncategorized')
    # Dynamic JSON object for additional product features
    feature_map = models.JSONField(
        default=dict, blank=True,
        help_text='Dynamic JSON object for additional features e.g. {"battery": {"image": "...", "content": "..."}}'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'products'
        ordering = ['-created_at']
        verbose_name = 'Product'
        verbose_name_plural = 'Products'

    def __str__(self):
        return f"{self.name} ({self.category}) — ${self.price}"

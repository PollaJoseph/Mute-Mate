from django.db import models
from django_mongodb_backend.fields import ObjectIdAutoField


class MuteUser(models.Model):
    """
    Represents a Mute-Mate platform user.
    Maps to the 'users' collection in MongoDB.
    This is a separate model from Django's built-in auth.User —
    it mirrors the exact document structure stored by the API views.
    """
    id = ObjectIdAutoField(primary_key=True)
    us_id = models.CharField(
        max_length=100, unique=True,
        help_text="Legacy UUID identifier used by the API views and JWT tokens"
    )
    us_full_name = models.CharField(max_length=255, verbose_name="Full Name")
    us_email = models.EmailField(unique=True, verbose_name="Email")
    us_phone_number = models.CharField(max_length=50, verbose_name="Phone Number")
    us_password = models.CharField(max_length=255, verbose_name="Password (hashed)")

    USER_TYPE_CHOICES = [
        ('standard', 'Standard'),
        ('premium', 'Premium'),
        ('admin', 'Admin'),
    ]
    us_user_type = models.CharField(
        max_length=50, choices=USER_TYPE_CHOICES, default='standard', verbose_name="User Type"
    )
    us_points_balance = models.IntegerField(default=0, verbose_name="Points Balance")
    us_daily_translation_count = models.IntegerField(default=0, verbose_name="Daily Translation Count")
    us_last_reset_date = models.DateTimeField(null=True, blank=True, verbose_name="Last Reset Date")
    us_subscription_plan_id = models.CharField(
        max_length=100, null=True, blank=True, verbose_name="Subscription Plan ID"
    )
    us_is_authenticated = models.BooleanField(default=False, verbose_name="Email Verified")
    last_login = models.DateTimeField(null=True, blank=True, verbose_name="Last Login")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'users'
        ordering = ['-created_at']
        verbose_name = 'Mute-Mate User'
        verbose_name_plural = 'Mute-Mate Users'

    def __str__(self):
        return f"{self.us_full_name} ({self.us_email}) — {self.us_user_type}"

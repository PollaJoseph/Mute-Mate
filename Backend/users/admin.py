from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.contrib.auth.admin import GroupAdmin as BaseGroupAdmin
from django.contrib.auth.models import User, Group
from unfold.admin import ModelAdmin
from .models import MuteUser

admin.site.unregister(User)
admin.site.unregister(Group)


@admin.register(User)
class UserAdmin(BaseUserAdmin, ModelAdmin):
    pass


@admin.register(Group)
class GroupAdmin(BaseGroupAdmin, ModelAdmin):
    pass


@admin.register(MuteUser)
class MuteUserAdmin(ModelAdmin):
    list_display = (
        'us_full_name', 'us_email', 'us_phone_number',
        'us_user_type', 'us_is_authenticated', 'us_points_balance', 'created_at'
    )
    list_filter = ('us_user_type', 'us_is_authenticated')
    search_fields = ('us_full_name', 'us_email', 'us_phone_number')
    readonly_fields = ('us_id', 'us_password', 'created_at', 'last_login')
    ordering = ('-created_at',)
    fieldsets = (
        ('Identity', {
            'fields': ('us_id', 'us_full_name', 'us_email', 'us_phone_number', 'us_password')
        }),
        ('Account Status', {
            'fields': ('us_user_type', 'us_is_authenticated', 'us_subscription_plan_id')
        }),
        ('Activity', {
            'fields': ('us_points_balance', 'us_daily_translation_count', 'us_last_reset_date', 'last_login')
        }),
        ('Timestamps', {
            'fields': ('created_at',)
        }),
    )

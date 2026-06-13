from django.contrib.admin.apps import AdminConfig
from django.contrib.auth.apps import AuthConfig
from django.contrib.contenttypes.apps import ContentTypesConfig

AdminConfig.default_auto_field = 'django_mongodb_backend.fields.ObjectIdAutoField'
AuthConfig.default_auto_field = 'django_mongodb_backend.fields.ObjectIdAutoField'
ContentTypesConfig.default_auto_field = 'django_mongodb_backend.fields.ObjectIdAutoField'


def _disconnect_create_permissions(**kwargs):
    """
    Workaround for django-mongodb-backend bug: the post_migrate signal's
    create_permissions handler crashes with 'Model instances without primary key
    value are unhashable' because ObjectId PKs aren't handled correctly yet.
    We disconnect it safely here so migrations still run correctly.
    """
    from django.contrib.auth.management import create_permissions
    from django.db.models.signals import post_migrate
    post_migrate.disconnect(create_permissions)


_disconnect_create_permissions()

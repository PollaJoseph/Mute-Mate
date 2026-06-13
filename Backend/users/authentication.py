import jwt
from datetime import datetime, timedelta, timezone
from django.conf import settings
from rest_framework import authentication
from rest_framework.exceptions import AuthenticationFailed
from MuteMate.db import db

def generate_tokens(user_id):
    access_payload = {
        'user_id': user_id,
        'exp': datetime.now(timezone.utc) + timedelta(days=settings.JWT_ACCESS_EXPIRATION_DAYS),
        'iat': datetime.now(timezone.utc),
        'type': 'access'
    }
    refresh_payload = {
        'user_id': user_id,
        'exp': datetime.now(timezone.utc) + timedelta(days=settings.JWT_REFRESH_EXPIRATION_DAYS),
        'iat': datetime.now(timezone.utc),
        'type': 'refresh'
    }
    
    access_token = jwt.encode(access_payload, settings.JWT_SECRET_KEY, algorithm='HS256')
    refresh_token = jwt.encode(refresh_payload, settings.JWT_SECRET_KEY, algorithm='HS256')
    
    return access_token, refresh_token

class CustomJWTAuthentication(authentication.BaseAuthentication):
    def authenticate(self, request):
        auth_header = request.headers.get('Authorization')
        if not auth_header:
            return None

        try:
            prefix, token = auth_header.split(' ')
            if prefix.lower() != 'bearer':
                return None
        except ValueError:
            return None

        try:
            payload = jwt.decode(token, settings.JWT_SECRET_KEY, algorithms=['HS256'])
        except jwt.ExpiredSignatureError:
            raise AuthenticationFailed('Token has expired')
        except jwt.InvalidTokenError:
            raise AuthenticationFailed('Invalid token')

        if payload.get('type') != 'access':
            raise AuthenticationFailed('Invalid token type')

        user_id = payload.get('user_id')
        user = db.users.find_one({"us_id": user_id})
        
        if not user:
            raise AuthenticationFailed('User not found')

        # DRF expects (user, auth)
        return (user, token)

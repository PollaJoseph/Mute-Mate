import uuid
from datetime import datetime
from django.contrib.auth.hashers import make_password, check_password
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi

import random
from MuteMate.db import db
from .authentication import generate_tokens
from .utils import send_otp_email

class SignUpView(APIView):
    permission_classes = [AllowAny]
    
    @swagger_auto_schema(
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            properties={
                'FullName': openapi.Schema(type=openapi.TYPE_STRING),
                'Email': openapi.Schema(type=openapi.TYPE_STRING),
                'PhoneNumber': openapi.Schema(type=openapi.TYPE_STRING),
                'Password': openapi.Schema(type=openapi.TYPE_STRING),
                'UserType': openapi.Schema(type=openapi.TYPE_STRING),
            },
            required=['FullName', 'Email', 'PhoneNumber', 'Password', 'UserType']
        ),
        responses={
            201: openapi.Response('Signup successful'),
            400: 'Email already registered'
        },
        operation_id="SignUp",
        operation_description="Registers a new user in Mute-Mate (Max Performance, No Serializer)."
    )
    def post(self, request):
        data = request.data
        email = data.get('Email', '').lower()
        
        # Check if email exists
        if db.users.find_one({"us_email": email}):
            return Response(
                {"Error": "Email already registered", "Status": 400},
                status=status.HTTP_400_BAD_REQUEST
            )
            
        # Generate 6-digit OTP
        otp_code = str(random.randint(100000, 999999))
        
        # Create new user directly from request data
        user_id = str(uuid.uuid4())
        user_data = {
            "us_id": user_id,
            "us_full_name": data.get('FullName'),
            "us_email": email,
            "us_phone_number": data.get('PhoneNumber'),
            "us_password": make_password(data.get('Password', '')),
            "us_user_type": data.get('UserType'),
            "us_points_balance": 0,
            "us_daily_translation_count": 0,
            "us_last_reset_date": datetime.now(),
            "us_subscription_plan_id": None,
            "us_is_authenticated": False,
            "otp_code": otp_code,
            "otp_created_at": datetime.now(),
            "created_at": datetime.now()
        }
        
        db.users.insert_one(user_data)
        
        # Send OTP asynchronously
        send_otp_email(email, otp_code)
        
        return Response(
            {"Status": 201, "Message": "Signup successful. Please verify your email with the OTP sent."},
            status=status.HTTP_201_CREATED
        )


class LoginView(APIView):
    permission_classes = [AllowAny]
    
    @swagger_auto_schema(
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            properties={
                'Email': openapi.Schema(type=openapi.TYPE_STRING),
                'Password': openapi.Schema(type=openapi.TYPE_STRING),
            },
            required=['Email', 'Password']
        ),
        responses={
            200: openapi.Response('Login successful', schema=openapi.Schema(
                type=openapi.TYPE_OBJECT,
                properties={
                    'ClientId': openapi.Schema(type=openapi.TYPE_STRING),
                    'Access': openapi.Schema(type=openapi.TYPE_STRING),
                    'Refresh': openapi.Schema(type=openapi.TYPE_STRING),
                    'Status': openapi.Schema(type=openapi.TYPE_INTEGER),
                }
            )),
            401: 'Invalid credentials'
        },
        operation_id="Login",
        operation_description="Authenticates a user and returns JWT tokens (Max Performance, No Serializer)."
    )
    def post(self, request):
        data = request.data
        email = data.get('Email', '').lower()
        password = data.get('Password', '')
        
        user = db.users.find_one({"us_email": email})
        
        if user and check_password(password, user.get('us_password')):
            # Generate JWT tokens
            access_token, refresh_token = generate_tokens(user['us_id'])
            
            # Update last login
            db.users.update_one(
                {"us_id": user['us_id']},
                {"$set": {"last_login": datetime.now()}}
            )
            
            return Response({
                "ClientId": user['us_id'],
                "Access": access_token,
                "Refresh": refresh_token,
                "Status": 200
            }, status=status.HTTP_200_OK)
            
        return Response(
            {"Error": "Invalid email or password", "Status": 401},
            status=status.HTTP_401_UNAUTHORIZED
        )

class VerifyOTPView(APIView):
    permission_classes = [AllowAny]
    
    @swagger_auto_schema(
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            properties={
                'Email': openapi.Schema(type=openapi.TYPE_STRING),
                'OTP': openapi.Schema(type=openapi.TYPE_STRING),
            },
            required=['Email', 'OTP']
        ),
        responses={
            200: openapi.Response('Verification successful', schema=openapi.Schema(
                type=openapi.TYPE_OBJECT,
                properties={
                    'ClientId': openapi.Schema(type=openapi.TYPE_STRING),
                    'Access': openapi.Schema(type=openapi.TYPE_STRING),
                    'Refresh': openapi.Schema(type=openapi.TYPE_STRING),
                    'Status': openapi.Schema(type=openapi.TYPE_INTEGER),
                }
            )),
            400: 'Invalid or expired OTP'
        },
        operation_id="VerifyOTP",
        operation_description="Verifies the OTP sent to email and returns JWT tokens."
    )
    def post(self, request):
        data = request.data
        email = data.get('Email', '').lower()
        otp_code = data.get('OTP', '')
        
        user = db.users.find_one({"us_email": email})
        
        if not user:
            return Response({"Error": "User not found", "Status": 404}, status=status.HTTP_404_NOT_FOUND)
            
        if user.get('otp_code') == otp_code:
            # Check expiration (e.g. 15 minutes)
            otp_created_at = user.get('otp_created_at')
            if otp_created_at and (datetime.now() - otp_created_at).total_seconds() > 900:
                return Response({"Error": "OTP has expired", "Status": 400}, status=status.HTTP_400_BAD_REQUEST)
                
            # Valid OTP - Update user
            db.users.update_one(
                {"us_id": user['us_id']},
                {
                    "$set": {"us_is_authenticated": True, "last_login": datetime.now()},
                    "$unset": {"otp_code": "", "otp_created_at": ""}
                }
            )
            
            # Generate Tokens
            access_token, refresh_token = generate_tokens(user['us_id'])
            
            return Response({
                "ClientId": user['us_id'],
                "Access": access_token,
                "Refresh": refresh_token,
                "Status": 200
            }, status=status.HTTP_200_OK)
            
        return Response(
            {"Error": "Invalid OTP", "Status": 400},
            status=status.HTTP_400_BAD_REQUEST
        )

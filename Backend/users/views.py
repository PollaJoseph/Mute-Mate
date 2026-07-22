import uuid
from datetime import datetime
from django.contrib.auth.hashers import make_password, check_password
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework import serializers
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi

import random
from MuteMate.db import db
from .authentication import generate_tokens
from .utils import send_otp_email

# Dummy serializers purely for professional Swagger UI rendering 
# (The views themselves remain Serializer-free for maximum performance)
class SignUpRequestSerializer(serializers.Serializer):
    FullName = serializers.CharField(required=True, help_text="User's full name")
    Email = serializers.EmailField(required=True, help_text="User's email address")
    PhoneNumber = serializers.CharField(required=True, help_text="User's phone number")
    Password = serializers.CharField(required=True, style={'input_type': 'password'}, help_text="Account password")
    UserType = serializers.CharField(required=False, help_text="Type of the user (e.g., standard, premium)", default="standard")

class LoginRequestSerializer(serializers.Serializer):
    Email = serializers.EmailField(required=True, help_text="User's registered email")
    Password = serializers.CharField(required=True, style={'input_type': 'password'}, help_text="Account password")

class VerifyOTPRequestSerializer(serializers.Serializer):
    Email = serializers.EmailField(required=True, help_text="User's email address")
    OTP = serializers.CharField(required=True, help_text="6-digit OTP code received via email")

class ResendOTPRequestSerializer(serializers.Serializer):
    Email = serializers.EmailField(required=True, help_text="User's email address")

class SignUpView(APIView):
    permission_classes = [AllowAny]
    
    @swagger_auto_schema(
        operation_id="SignUp",
        operation_summary="Register a new user",
        operation_description="""
        Creates a new user account in the Mute-Mate platform and sends an OTP to their email for verification.
        
        **Required Fields:**
        * **FullName** - The user's full name.
        * **Email** - The user's email address (must be unique).
        * **PhoneNumber** - The user's contact number.
        * **Password** - A strong password.
        
        **Optional Fields:**
        * **UserType** - The role or type of the user.
        """,
        tags=['Authentication'],
        request_body=SignUpRequestSerializer,
        responses={
            201: openapi.Response('Signup successful', openapi.Schema(
                type=openapi.TYPE_OBJECT,
                properties={
                    'Status': openapi.Schema(type=openapi.TYPE_INTEGER, example=201),
                    'Message': openapi.Schema(type=openapi.TYPE_STRING, example="Signup successful. Please verify your email with the OTP sent.")
                }
            )),
            400: openapi.Response('Bad Request - Email already registered', openapi.Schema(
                type=openapi.TYPE_OBJECT,
                properties={
                    'Error': openapi.Schema(type=openapi.TYPE_STRING, example="Email already registered"),
                    'Status': openapi.Schema(type=openapi.TYPE_INTEGER, example=400)
                }
            ))
        }
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
        operation_id="Login",
        operation_summary="Authenticate user via email and password",
        operation_description="""
        Authenticates a user using their email and password. 
        Upon successful authentication, this endpoint returns an Access Token and a Refresh Token, which should be used to authenticate subsequent requests.
        """,
        tags=['Authentication'],
        request_body=LoginRequestSerializer,
        responses={
            200: openapi.Response('Login successful', openapi.Schema(
                type=openapi.TYPE_OBJECT,
                properties={
                    'ClientId': openapi.Schema(type=openapi.TYPE_STRING, description="Unique user identifier", example="uuid-string-here"),
                    'Access': openapi.Schema(type=openapi.TYPE_STRING, description="JWT Access Token", example="eyJhbGci..."),
                    'Refresh': openapi.Schema(type=openapi.TYPE_STRING, description="JWT Refresh Token", example="eyJhbGci..."),
                    'Status': openapi.Schema(type=openapi.TYPE_INTEGER, example=200),
                }
            )),
            401: openapi.Response('Unauthorized - Invalid credentials', openapi.Schema(
                type=openapi.TYPE_OBJECT,
                properties={
                    'Error': openapi.Schema(type=openapi.TYPE_STRING, example="Invalid email or password"),
                    'Status': openapi.Schema(type=openapi.TYPE_INTEGER, example=401)
                }
            ))
        }
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
        operation_id="VerifyOTP",
        operation_summary="Verify One-Time Password (OTP)",
        operation_description="""
        Verifies the 6-digit OTP sent to the user's email during signup or a password reset process. 
        If valid, the user's account is marked as authenticated and JWT tokens are returned for immediate login.
        
        **Note:** OTPs expire after 15 minutes.
        """,
        tags=['Authentication'],
        request_body=VerifyOTPRequestSerializer,
        responses={
            200: openapi.Response('Verification successful', openapi.Schema(
                type=openapi.TYPE_OBJECT,
                properties={
                    'ClientId': openapi.Schema(type=openapi.TYPE_STRING, description="Unique user identifier", example="uuid-string-here"),
                    'Access': openapi.Schema(type=openapi.TYPE_STRING, description="JWT Access Token", example="eyJhbGci..."),
                    'Refresh': openapi.Schema(type=openapi.TYPE_STRING, description="JWT Refresh Token", example="eyJhbGci..."),
                    'Status': openapi.Schema(type=openapi.TYPE_INTEGER, example=200),
                }
            )),
            400: openapi.Response('Bad Request - Invalid or expired OTP', openapi.Schema(
                type=openapi.TYPE_OBJECT,
                properties={
                    'Error': openapi.Schema(type=openapi.TYPE_STRING, example="Invalid OTP"),
                    'Status': openapi.Schema(type=openapi.TYPE_INTEGER, example=400)
                }
            )),
            404: openapi.Response('Not Found - User not found', openapi.Schema(
                type=openapi.TYPE_OBJECT,
                properties={
                    'Error': openapi.Schema(type=openapi.TYPE_STRING, example="User not found"),
                    'Status': openapi.Schema(type=openapi.TYPE_INTEGER, example=404)
                }
            ))
        }
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

class ResendOTPView(APIView):
    permission_classes = [AllowAny]
    
    @swagger_auto_schema(
        operation_id="ResendOTP",
        operation_summary="Resend Verification OTP",
        operation_description="""
        Generates a new 6-digit OTP and sends it to the user's registered email address.
        Useful when the previous OTP has expired or was not received.
        """,
        tags=['Authentication'],
        request_body=ResendOTPRequestSerializer,
        responses={
            200: openapi.Response('OTP resent successfully', openapi.Schema(
                type=openapi.TYPE_OBJECT,
                properties={
                    'Status': openapi.Schema(type=openapi.TYPE_INTEGER, example=200),
                    'Message': openapi.Schema(type=openapi.TYPE_STRING, example="A new OTP has been sent to your email.")
                }
            )),
            404: openapi.Response('Not Found - User not found', openapi.Schema(
                type=openapi.TYPE_OBJECT,
                properties={
                    'Error': openapi.Schema(type=openapi.TYPE_STRING, example="User not found"),
                    'Status': openapi.Schema(type=openapi.TYPE_INTEGER, example=404)
                }
            ))
        }
    )
    def post(self, request):
        data = request.data
        email = data.get('Email', '').lower()
        
        user = db.users.find_one({"us_email": email})
        
        if not user:
            return Response({"Error": "User not found", "Status": 404}, status=status.HTTP_404_NOT_FOUND)
            
        # Generate new 6-digit OTP
        otp_code = str(random.randint(100000, 999999))
        
        # Update user in DB
        db.users.update_one(
            {"us_email": email},
            {"$set": {
                "otp_code": otp_code,
                "otp_created_at": datetime.now()
            }}
        )
        
        # Send new OTP
        send_otp_email(email, otp_code)
        
        return Response(
            {"Status": 200, "Message": "A new OTP has been sent to your email."},
            status=status.HTTP_200_OK
        )

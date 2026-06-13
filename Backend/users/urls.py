from django.urls import path
from .views import SignUpView, LoginView, VerifyOTPView

app_name = 'users'

urlpatterns = [
    path('SignUp/', SignUpView.as_view(), name='signup'),
    path('Login/', LoginView.as_view(), name='login'),
    path('VerifyOTP/', VerifyOTPView.as_view(), name='verify-otp'),
]

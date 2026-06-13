from django.core.mail import EmailMultiAlternatives
from django.template.loader import render_to_string
from django.utils.html import strip_tags
from django.conf import settings
import threading
import logging

logger = logging.getLogger(__name__)

def send_otp_email_sync(email, otp_code):
    try:
        subject = 'Your Mute-Mate Authentication Code'
        
        # HTML Content
        # We assume you will create templates/otp_email.html later. 
        # For now, we provide a basic fallback inline HTML if the template doesn't exist.
        try:
            html_content = render_to_string('otp_email.html', {'otp_code': otp_code})
        except Exception:
            # Fallback if the template is not yet created
            html_content = f"""
            <html>
                <body>
                    <h2>Welcome to Mute-Mate!</h2>
                    <p>Your authentication code is: <strong>{otp_code}</strong></p>
                    <p>This code will expire in 15 minutes.</p>
                </body>
            </html>
            """
            
        text_content = strip_tags(html_content)
        
        msg = EmailMultiAlternatives(
            subject,
            text_content,
            settings.EMAIL_HOST_USER,
            [email]
        )
        msg.attach_alternative(html_content, "text/html")
        msg.send()
        
    except Exception as e:
        logger.error(f"Failed to send OTP email to {email}: {str(e)}")

def send_otp_email(email, otp_code):
    """
    Sends the OTP email asynchronously so it doesn't block the API response.
    """
    thread = threading.Thread(target=send_otp_email_sync, args=(email, otp_code))
    thread.start()

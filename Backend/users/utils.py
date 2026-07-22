from django.core.mail import EmailMultiAlternatives
from email.mime.image import MIMEImage
import os
import threading
import logging
from django.template.loader import render_to_string
from django.utils.html import strip_tags
from django.conf import settings

logger = logging.getLogger(__name__)

class EmailRelatedAlternatives(EmailMultiAlternatives):
    def message(self, *args, **kwargs):
        msg = super().message(*args, **kwargs)
        content_type = msg.get('Content-Type', '')
        if 'multipart/mixed' in content_type:
            msg.replace_header('Content-Type', content_type.replace('multipart/mixed', 'multipart/related'))
        return msg

def send_otp_email_sync(email, otp_code):
    try:
        subject = 'Your Mute-Mate Authentication Code'
        
        try:
            html_content = render_to_string('otp_email.html', {'otp_code': otp_code})
        except Exception:
            html_content = f"<html><body><p>Your authentication code is: <strong>{otp_code}</strong></p></body></html>"
            
        text_content = strip_tags(html_content)
        
        msg = EmailRelatedAlternatives(
            subject,
            text_content,
            settings.EMAIL_HOST_USER,
            [email]
        )
        msg.attach_alternative(html_content, "text/html")
        
        # Embed MuteMedia inline images for the template
        images = ['logo.png', 'communication.png', 'instagram.png', 'tik-tok.png', 'linkedin.png']
        media_path = os.path.join(settings.BASE_DIR, 'MuteMedia')
        
        for img_name in images:
            img_path = os.path.join(media_path, img_name)
            if os.path.exists(img_path):
                with open(img_path, 'rb') as f:
                    img = MIMEImage(f.read())
                    img.add_header('Content-ID', f'<{img_name}>')
                    img.add_header('Content-Disposition', 'inline')
                    msg.attach(img)
                    
        msg.send()
        
    except Exception as e:
        logger.error(f"Failed to send OTP email to {email}: {str(e)}")

def send_otp_email(email, otp_code):
    """
    Sends the OTP email asynchronously so it doesn't block the API response.
    """
    thread = threading.Thread(target=send_otp_email_sync, args=(email, otp_code))
    thread.start()

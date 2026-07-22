from django.db import models

class ChatSession(models.Model):
    # JSONField will hold a list of emails like ["user1@example.com", "user2@example.com"]
    participants = models.JSONField(default=list)
    created_at = models.DateTimeField(auto_now_add=True)
    last_message_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"ChatSession ({self.id})"

class Message(models.Model):
    session = models.ForeignKey(ChatSession, on_delete=models.CASCADE, related_name='messages')
    sender_email = models.CharField(max_length=255)
    content = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)
    is_read = models.BooleanField(default=False)

    def __str__(self):
        return f"Message from {self.sender_email} at {self.timestamp}"

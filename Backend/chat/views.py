from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework import serializers
from .models import ChatSession, Message
from django.utils import timezone
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi

class StartChatRequestSerializer(serializers.Serializer):
    my_email = serializers.EmailField(required=True, help_text="The sender's email")
    target_email = serializers.EmailField(required=True, help_text="The recipient's email")

class SendMessageRequestSerializer(serializers.Serializer):
    my_email = serializers.EmailField(required=True, help_text="The sender's email")
    content = serializers.CharField(required=True, help_text="The message content")

class StartChatView(APIView):
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        operation_id="StartChat",
        operation_summary="Start a chat session",
        operation_description="""
        Initializes a chat session with another user. Requires JWT Token.
        
        **Note:** If a session already exists between the two users, it will return the existing `SessionId` rather than creating a new one.
        """,
        tags=['Chat'],
        security=[{'Bearer': []}],
        request_body=StartChatRequestSerializer,
        responses={
            200: openapi.Response('Existing session returned', openapi.Schema(
                type=openapi.TYPE_OBJECT,
                properties={
                    'Status': openapi.Schema(type=openapi.TYPE_INTEGER, example=200),
                    'SessionId': openapi.Schema(type=openapi.TYPE_STRING, example="uuid-string-here")
                }
            )),
            201: openapi.Response('New session created', openapi.Schema(
                type=openapi.TYPE_OBJECT,
                properties={
                    'Status': openapi.Schema(type=openapi.TYPE_INTEGER, example=201),
                    'SessionId': openapi.Schema(type=openapi.TYPE_STRING, example="uuid-string-here")
                }
            )),
            400: openapi.Response('Bad Request')
        }
    )
    def post(self, request):
        my_email = request.data.get('my_email')
        target_email = request.data.get('target_email')

        if not my_email or not target_email:
            return Response({"Error": "Missing my_email or target_email", "Status": 400}, status=status.HTTP_400_BAD_REQUEST)

        if my_email == target_email:
            return Response({"Error": "Cannot chat with yourself", "Status": 400}, status=status.HTTP_400_BAD_REQUEST)

        sessions = ChatSession.objects.filter(participants__contains=my_email).filter(participants__contains=target_email)
        if sessions.exists():
            return Response({"Status": 200, "SessionId": str(sessions.first().id)}, status=status.HTTP_200_OK)
            
        session = ChatSession.objects.create(participants=[my_email, target_email])
        return Response({"Status": 201, "SessionId": str(session.id)}, status=status.HTTP_201_CREATED)

class ListSessionsView(APIView):
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        operation_id="ListSessions",
        operation_summary="List active chat sessions",
        operation_description="Retrieves the user's inbox containing all chat sessions they are a participant of. The sessions are sorted by the latest activity. Requires JWT Token.",
        tags=['Chat'],
        security=[{'Bearer': []}],
        manual_parameters=[
            openapi.Parameter('my_email', openapi.IN_QUERY, description="The user's email", type=openapi.TYPE_STRING, required=True)
        ],
        responses={
            200: openapi.Response('List of active chat sessions', openapi.Schema(
                type=openapi.TYPE_OBJECT,
                properties={
                    'Status': openapi.Schema(type=openapi.TYPE_INTEGER, example=200),
                    'Data': openapi.Schema(
                        type=openapi.TYPE_ARRAY,
                        items=openapi.Schema(
                            type=openapi.TYPE_OBJECT,
                            properties={
                                'SessionId': openapi.Schema(type=openapi.TYPE_STRING),
                                'Participants': openapi.Schema(type=openapi.TYPE_ARRAY, items=openapi.Items(type=openapi.TYPE_STRING)),
                                'LastActivity': openapi.Schema(type=openapi.TYPE_STRING, format=openapi.FORMAT_DATETIME),
                                'Preview': openapi.Schema(type=openapi.TYPE_STRING)
                            }
                        )
                    )
                }
            ))
        }
    )
    def get(self, request):
        my_email = request.GET.get('my_email')
        if not my_email:
            return Response({"Error": "Missing my_email", "Status": 400}, status=status.HTTP_400_BAD_REQUEST)
            
        sessions = ChatSession.objects.filter(participants__contains=my_email).order_by('-last_message_at')
        
        data = []
        for s in sessions:
            last_msg = s.messages.order_by('-timestamp').first()
            preview = last_msg.content if last_msg else ""
            
            data.append({
                "SessionId": str(s.id),
                "Participants": s.participants,
                "LastActivity": s.last_message_at,
                "Preview": preview
            })
            
        return Response({"Status": 200, "Data": data}, status=status.HTTP_200_OK)

class SendMessageView(APIView):
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        operation_id="SendMessage",
        operation_summary="Send a message",
        operation_description="Sends a new text message into the specified chat session. Requires JWT Token.",
        tags=['Chat'],
        security=[{'Bearer': []}],
        request_body=SendMessageRequestSerializer,
        responses={
            201: openapi.Response('Message sent successfully', openapi.Schema(
                type=openapi.TYPE_OBJECT,
                properties={
                    'Status': openapi.Schema(type=openapi.TYPE_INTEGER, example=201),
                    'Message': openapi.Schema(type=openapi.TYPE_STRING, example="Sent"),
                    'MessageId': openapi.Schema(type=openapi.TYPE_STRING, example="uuid-string-here")
                }
            )),
            400: openapi.Response('Bad Request'),
            403: openapi.Response('Forbidden'),
            404: openapi.Response('Not Found')
        }
    )
    def post(self, request, session_id):
        my_email = request.data.get('my_email')
        content = request.data.get('content')
        
        if not my_email or not content:
            return Response({"Error": "Missing my_email or content", "Status": 400}, status=status.HTTP_400_BAD_REQUEST)
            
        try:
            session = ChatSession.objects.get(id=session_id)
        except ChatSession.DoesNotExist:
            return Response({"Error": "Session not found", "Status": 404}, status=status.HTTP_404_NOT_FOUND)
            
        if my_email not in session.participants:
            return Response({"Error": "Not authorized to send in this session", "Status": 403}, status=status.HTTP_403_FORBIDDEN)
            
        msg = Message.objects.create(
            session=session,
            sender_email=my_email,
            content=content
        )
        
        session.last_message_at = msg.timestamp
        session.save()
        
        return Response({"Status": 201, "Message": "Sent", "MessageId": str(msg.id)}, status=status.HTTP_201_CREATED)

class ListMessagesView(APIView):
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        operation_id="ListMessages",
        operation_summary="List messages in a session",
        operation_description="Retrieves all messages for a specific session. Suitable for fetching the chat history. Requires JWT Token.",
        tags=['Chat'],
        security=[{'Bearer': []}],
        manual_parameters=[
            openapi.Parameter('my_email', openapi.IN_QUERY, description="The user's email", type=openapi.TYPE_STRING, required=True)
        ],
        responses={
            200: openapi.Response('Messages retrieved', openapi.Schema(
                type=openapi.TYPE_OBJECT,
                properties={
                    'Status': openapi.Schema(type=openapi.TYPE_INTEGER, example=200),
                    'Data': openapi.Schema(
                        type=openapi.TYPE_ARRAY,
                        items=openapi.Schema(
                            type=openapi.TYPE_OBJECT,
                            properties={
                                'MessageId': openapi.Schema(type=openapi.TYPE_STRING),
                                'Sender': openapi.Schema(type=openapi.TYPE_STRING),
                                'Content': openapi.Schema(type=openapi.TYPE_STRING),
                                'Timestamp': openapi.Schema(type=openapi.TYPE_STRING, format=openapi.FORMAT_DATETIME),
                                'IsRead': openapi.Schema(type=openapi.TYPE_BOOLEAN)
                            }
                        )
                    )
                }
            )),
            403: openapi.Response('Forbidden'),
            404: openapi.Response('Not Found')
        }
    )
    def get(self, request, session_id):
        my_email = request.GET.get('my_email')
        if not my_email:
            return Response({"Error": "Missing my_email", "Status": 400}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            session = ChatSession.objects.get(id=session_id)
        except ChatSession.DoesNotExist:
            return Response({"Error": "Session not found", "Status": 404}, status=status.HTTP_404_NOT_FOUND)
            
        if my_email not in session.participants:
            return Response({"Error": "Not authorized to view this session", "Status": 403}, status=status.HTTP_403_FORBIDDEN)
            
        messages = session.messages.order_by('timestamp')
        
        data = []
        for m in messages:
            data.append({
                "MessageId": str(m.id),
                "Sender": m.sender_email,
                "Content": m.content,
                "Timestamp": m.timestamp,
                "IsRead": m.is_read
            })
            
        return Response({"Status": 200, "Data": data}, status=status.HTTP_200_OK)

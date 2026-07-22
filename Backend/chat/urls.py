from django.urls import path
from .views import StartChatView, ListSessionsView, SendMessageView, ListMessagesView

app_name = 'chat'

urlpatterns = [
    path('Start/', StartChatView.as_view(), name='start-chat'),
    path('Sessions/', ListSessionsView.as_view(), name='list-sessions'),
    path('<str:session_id>/Send/', SendMessageView.as_view(), name='send-message'),
    path('<str:session_id>/Messages/', ListMessagesView.as_view(), name='list-messages'),
]

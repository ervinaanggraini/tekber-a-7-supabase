from app.extensions import db
import uuid
from sqlalchemy import Uuid
from datetime import datetime, timezone

class ChatConversation(db.Model):
    __tablename__ = 'chat_conversations'

    id = db.Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = db.Column(Uuid(as_uuid=True), db.ForeignKey('user_profiles.id'), nullable=False)
    title = db.Column(db.Text, nullable=True)
    persona = db.Column(db.Text, nullable=False) # angry_mom, supportive_cheerleader, wise_mentor
    context_summary = db.Column(db.Text, nullable=True)
    last_message_at = db.Column(db.DateTime, nullable=True)
    is_archived = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))

    user = db.relationship('UserProfile', backref='conversations')

class ChatMessage(db.Model):
    __tablename__ = 'chat_messages'

    id = db.Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    conversation_id = db.Column(Uuid(as_uuid=True), db.ForeignKey('chat_conversations.id'), nullable=False)
    role = db.Column(db.Text, nullable=False) # user, assistant, system
    content = db.Column(db.Text, nullable=False)
    persona = db.Column(db.Text, nullable=True)
    intent = db.Column(db.Text, nullable=True)
    extracted_data = db.Column(db.JSON, nullable=True)
    transaction_id = db.Column(Uuid(as_uuid=True), db.ForeignKey('transactions.id'), nullable=True)
    image_url = db.Column(db.Text, nullable=True)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))

    conversation = db.relationship('ChatConversation', backref='messages')
    # transaction = db.relationship('Transaction')

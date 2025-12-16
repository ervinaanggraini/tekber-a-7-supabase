from app.extensions import db
import uuid
from sqlalchemy import Uuid
from datetime import datetime, timezone

class UserSettings(db.Model):
    __tablename__ = 'user_settings'

    id = db.Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = db.Column(Uuid(as_uuid=True), db.ForeignKey('user_profiles.id'), nullable=False, unique=True)
    enable_notifications = db.Column(db.Boolean, default=True)
    enable_daily_reminders = db.Column(db.Boolean, default=True)
    enable_mission_alerts = db.Column(db.Boolean, default=True)
    enable_budget_alerts = db.Column(db.Boolean, default=True)
    currency = db.Column(db.Text, default='IDR')
    language = db.Column(db.Text, default='id')
    theme = db.Column(db.Text, default='light') # light, dark, auto
    enable_ai_insights = db.Column(db.Boolean, default=True)
    enable_ocr = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    user = db.relationship('UserProfile', backref=db.backref('settings', uselist=False))

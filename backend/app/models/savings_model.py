from app.extensions import db
import uuid
from sqlalchemy import Uuid
from datetime import datetime, timezone

class SavingsGoal(db.Model):
    __tablename__ = 'savings_goals'

    id = db.Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = db.Column(Uuid(as_uuid=True), db.ForeignKey('users.id'), nullable=False)
    target_amount = db.Column(db.Numeric(15, 2), default=1000000.00, nullable=False)
    deadline = db.Column(db.Date, nullable=False)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    user = db.relationship('User', backref='savings_goals')

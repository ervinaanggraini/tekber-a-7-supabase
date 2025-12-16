from app.extensions import db
import uuid
from sqlalchemy import Uuid
from datetime import datetime, timezone

class Course(db.Model):
    __tablename__ = 'courses'

    id = db.Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = db.Column(db.Text, nullable=False)
    description = db.Column(db.Text, nullable=True)
    thumbnail_url = db.Column(db.Text, nullable=True)
    level = db.Column(db.Text, default='beginner') # beginner, intermediate, advanced
    category = db.Column(db.Text, nullable=True) # stocks, crypto, bonds, forex, fundamental, technology
    duration_minutes = db.Column(db.Integer, nullable=True)
    content = db.Column(db.JSON, nullable=False)
    xp_reward = db.Column(db.Integer, default=0)
    is_published = db.Column(db.Boolean, default=True)
    order_index = db.Column(db.Integer, default=0)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

class UserCourseProgress(db.Model):
    __tablename__ = 'user_course_progress'

    id = db.Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = db.Column(Uuid(as_uuid=True), db.ForeignKey('user_profiles.id'), nullable=False)
    course_id = db.Column(Uuid(as_uuid=True), db.ForeignKey('courses.id'), nullable=False)
    read_articles = db.Column(db.JSON, default=[])
    total_articles_read = db.Column(db.Integer, default=0)
    last_accessed_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))

    user = db.relationship('UserProfile', backref='course_progress')
    course = db.relationship('Course')

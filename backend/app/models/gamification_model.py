from app.extensions import db
import uuid
from sqlalchemy import Uuid
from datetime import datetime, timezone

class UserProfile(db.Model):
    __tablename__ = 'user_profiles'

    id = db.Column(Uuid(as_uuid=True), db.ForeignKey('users.id'), primary_key=True)
    full_name = db.Column(db.String(100), nullable=False)
    avatar_url = db.Column(db.String(255), nullable=True)
    phone_number = db.Column(db.String(20), nullable=True)
    date_of_birth = db.Column(db.Date, nullable=True)
    level = db.Column(db.Integer, default=1)
    total_xp = db.Column(db.Integer, default=0)
    total_points = db.Column(db.Integer, default=0)
    current_streak = db.Column(db.Integer, default=0)
    longest_streak = db.Column(db.Integer, default=0)
    last_activity_date = db.Column(db.Date, nullable=True)
    monthly_income = db.Column(db.Numeric(15, 2), nullable=True)
    risk_profile = db.Column(db.String(20), nullable=True) # conservative, moderate, aggressive
    financial_goals = db.Column(db.JSON, default=[])
    preferred_chatbot_persona = db.Column(db.String(50), default='wise_mentor')
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    # Relationships
    user = db.relationship('User', backref=db.backref('profile', uselist=False))

class Badge(db.Model):
    __tablename__ = 'badges'

    id = db.Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = db.Column(db.String(100), nullable=False, unique=True)
    description = db.Column(db.Text, nullable=True)
    icon = db.Column(db.String(255), nullable=True)
    category = db.Column(db.String(50), nullable=True) # tracking, saving, investment, streak, special
    rarity = db.Column(db.String(20), default='common') # common, rare, epic, legendary
    xp_reward = db.Column(db.Integer, default=0)
    requirement_type = db.Column(db.String(50), nullable=True)
    requirement_value = db.Column(db.Integer, nullable=True)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))

class UserBadge(db.Model):
    __tablename__ = 'user_badges'

    id = db.Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = db.Column(Uuid(as_uuid=True), db.ForeignKey('user_profiles.id'), nullable=False)
    badge_id = db.Column(Uuid(as_uuid=True), db.ForeignKey('badges.id'), nullable=False)
    earned_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))

    user = db.relationship('UserProfile', backref='badges')
    badge = db.relationship('Badge')

class Mission(db.Model):
    __tablename__ = 'missions'

    id = db.Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text, nullable=True)
    type = db.Column(db.String(50), nullable=False) # daily, weekly, monthly, special, achievement
    category = db.Column(db.String(50), nullable=True) # tracking, saving, investment, education, social
    xp_reward = db.Column(db.Integer, default=0)
    points_reward = db.Column(db.Integer, default=0)
    requirement_type = db.Column(db.String(50), nullable=False)
    requirement_value = db.Column(db.Integer, nullable=False)
    requirement_data = db.Column(db.JSON, nullable=True)
    is_active = db.Column(db.Boolean, default=True)
    difficulty = db.Column(db.String(20), default='easy') # easy, medium, hard
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))

class UserMission(db.Model):
    __tablename__ = 'user_missions'

    id = db.Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = db.Column(Uuid(as_uuid=True), db.ForeignKey('user_profiles.id'), nullable=False)
    mission_id = db.Column(Uuid(as_uuid=True), db.ForeignKey('missions.id'), nullable=False)
    current_progress = db.Column(db.Integer, default=0)
    target_progress = db.Column(db.Integer, nullable=False)
    status = db.Column(db.String(20), default='in_progress') # in_progress, completed, claimed, expired
    started_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    completed_at = db.Column(db.DateTime, nullable=True)
    expires_at = db.Column(db.DateTime, nullable=True)

    user = db.relationship('UserProfile', backref='missions')
    mission = db.relationship('Mission')

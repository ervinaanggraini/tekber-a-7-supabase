from app.extensions import db
import uuid
from sqlalchemy import Uuid
from datetime import datetime, timezone

class FinancialInsight(db.Model):
    __tablename__ = 'financial_insights'

    id = db.Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = db.Column(Uuid(as_uuid=True), db.ForeignKey('user_profiles.id'), nullable=False)
    type = db.Column(db.Text, nullable=False) # spending_pattern, saving_tip, budget_alert, investment_advice, trend_analysis
    title = db.Column(db.Text, nullable=False)
    content = db.Column(db.Text, nullable=False)
    priority = db.Column(db.Text, default='medium') # low, medium, high
    suggested_actions = db.Column(db.JSON, nullable=True)
    related_category_id = db.Column(Uuid(as_uuid=True), db.ForeignKey('categories.id'), nullable=True)
    related_transaction_ids = db.Column(db.JSON, nullable=True)
    analysis_data = db.Column(db.JSON, nullable=True)
    is_read = db.Column(db.Boolean, default=False)
    is_dismissed = db.Column(db.Boolean, default=False)
    valid_until = db.Column(db.Date, nullable=True)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))

    user = db.relationship('UserProfile', backref='insights')
    # category relationship if needed

class SpendingPattern(db.Model):
    __tablename__ = 'spending_patterns'

    id = db.Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = db.Column(Uuid(as_uuid=True), db.ForeignKey('user_profiles.id'), nullable=False)
    period_start = db.Column(db.Date, nullable=False)
    period_end = db.Column(db.Date, nullable=False)
    period_type = db.Column(db.Text, nullable=False) # weekly, monthly, quarterly, yearly
    total_income = db.Column(db.Numeric(15, 2), default=0)
    total_expense = db.Column(db.Numeric(15, 2), default=0)
    net_savings = db.Column(db.Numeric(15, 2), default=0)
    top_categories = db.Column(db.JSON, nullable=True)
    spending_trends = db.Column(db.JSON, nullable=True)
    ai_summary = db.Column(db.Text, nullable=True)
    ai_recommendations = db.Column(db.JSON, nullable=True)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))

    user = db.relationship('UserProfile', backref='spending_patterns')

class Category(db.Model):
    __tablename__ = 'categories'

    id = db.Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = db.Column(db.Text, nullable=False)
    type = db.Column(db.Text, nullable=False) # income, expense
    icon = db.Column(db.Text, nullable=True)
    color = db.Column(db.Text, nullable=True)
    is_system = db.Column(db.Boolean, default=False)
    user_id = db.Column(Uuid(as_uuid=True), db.ForeignKey('user_profiles.id'), nullable=True)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))

    user = db.relationship('UserProfile', backref='categories')

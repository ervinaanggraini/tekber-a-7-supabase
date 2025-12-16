from app.extensions import db
import uuid
from sqlalchemy import Uuid
from datetime import datetime, timezone

class VirtualPortfolio(db.Model):
    __tablename__ = 'virtual_portfolios'

    id = db.Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = db.Column(Uuid(as_uuid=True), db.ForeignKey('user_profiles.id'), nullable=False)
    name = db.Column(db.Text, default='My Portfolio')
    initial_balance = db.Column(db.Numeric(15, 2), default=10000000.00)
    current_balance = db.Column(db.Numeric(15, 2), default=10000000.00)
    total_profit_loss = db.Column(db.Numeric(15, 2), default=0)
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    user = db.relationship('UserProfile', backref='virtual_portfolios')

class VirtualPosition(db.Model):
    __tablename__ = 'virtual_positions'

    id = db.Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    portfolio_id = db.Column(Uuid(as_uuid=True), db.ForeignKey('virtual_portfolios.id'), nullable=False)
    asset_symbol = db.Column(db.Text, nullable=False)
    asset_type = db.Column(db.Text, nullable=False) # stock, crypto, forex, commodity
    asset_name = db.Column(db.Text, nullable=True)
    quantity = db.Column(db.Numeric(15, 8), nullable=False)
    entry_price = db.Column(db.Numeric(15, 2), nullable=False)
    current_price = db.Column(db.Numeric(15, 2), nullable=True)
    profit_loss = db.Column(db.Numeric(15, 2), default=0)
    profit_loss_percentage = db.Column(db.Numeric(5, 2), default=0)
    opened_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    closed_at = db.Column(db.DateTime, nullable=True)
    status = db.Column(db.Text, default='open') # open, closed

    portfolio = db.relationship('VirtualPortfolio', backref='positions')

class VirtualTransaction(db.Model):
    __tablename__ = 'virtual_transactions'

    id = db.Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    portfolio_id = db.Column(Uuid(as_uuid=True), db.ForeignKey('virtual_portfolios.id'), nullable=False)
    position_id = db.Column(Uuid(as_uuid=True), db.ForeignKey('virtual_positions.id'), nullable=True)
    type = db.Column(db.Text, nullable=False) # buy, sell
    asset_symbol = db.Column(db.Text, nullable=False)
    asset_type = db.Column(db.Text, nullable=False)
    quantity = db.Column(db.Numeric(15, 8), nullable=False)
    price = db.Column(db.Numeric(15, 2), nullable=False)
    total_amount = db.Column(db.Numeric(15, 2), nullable=False)
    fee = db.Column(db.Numeric(15, 2), default=0)
    notes = db.Column(db.Text, nullable=True)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))

    portfolio = db.relationship('VirtualPortfolio', backref='transactions')
    position = db.relationship('VirtualPosition', backref='transactions')

class InvestmentChallenge(db.Model):
    __tablename__ = 'investment_challenges'

    id = db.Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = db.Column(db.Text, nullable=False)
    description = db.Column(db.Text, nullable=True)
    type = db.Column(db.Text, nullable=True) # diversification, profit_target, risk_management, trading_frequency
    target_value = db.Column(db.Numeric(15, 2), nullable=True)
    duration_days = db.Column(db.Integer, nullable=True)
    xp_reward = db.Column(db.Integer, default=0)
    points_reward = db.Column(db.Integer, default=0)
    difficulty = db.Column(db.Text, default='easy')
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))

class UserInvestmentChallenge(db.Model):
    __tablename__ = 'user_investment_challenges'

    id = db.Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = db.Column(Uuid(as_uuid=True), db.ForeignKey('user_profiles.id'), nullable=False)
    challenge_id = db.Column(Uuid(as_uuid=True), db.ForeignKey('investment_challenges.id'), nullable=False)
    progress_data = db.Column(db.JSON, default={})
    status = db.Column(db.Text, default='in_progress') # in_progress, completed, failed, claimed
    started_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    completed_at = db.Column(db.DateTime, nullable=True)

    user = db.relationship('UserProfile', backref='investment_challenges')
    challenge = db.relationship('InvestmentChallenge')

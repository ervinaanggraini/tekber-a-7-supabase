from app.extensions import db
import uuid
from sqlalchemy import Uuid
from datetime import datetime, timezone

class InvestmentPortfolio(db.Model):
    __tablename__ = 'investment_portfolios'

    id = db.Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = db.Column(Uuid(as_uuid=True), db.ForeignKey('users.id'), nullable=False, unique=True)
    virtual_cash = db.Column(db.Float, default=100000000.0)
    xp = db.Column(db.Integer, default=0)
    level = db.Column(db.Integer, default=1)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    # Relationships
    assets = db.relationship('InvestmentAsset', backref='portfolio', lazy=True, cascade="all, delete-orphan")
    transactions = db.relationship('InvestmentTransaction', backref='portfolio', lazy=True, cascade="all, delete-orphan")

    def to_dict(self):
        return {
            'id': str(self.id),
            'user_id': str(self.user_id),
            'virtual_cash': self.virtual_cash,
            'xp': self.xp,
            'level': self.level,
            'assets': [asset.to_dict() for asset in self.assets],
            'transactions': [t.to_dict() for t in self.transactions]
        }

class InvestmentAsset(db.Model):
    __tablename__ = 'investment_assets'

    id = db.Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    portfolio_id = db.Column(Uuid(as_uuid=True), db.ForeignKey('investment_portfolios.id'), nullable=False)
    asset_code = db.Column(db.String(10), nullable=False)
    asset_name = db.Column(db.String(100), nullable=False)
    quantity = db.Column(db.Float, default=0.0)
    avg_price = db.Column(db.Float, default=0.0)
    
    def to_dict(self):
        return {
            'id': str(self.id),
            'asset_code': self.asset_code,
            'asset_name': self.asset_name,
            'quantity': self.quantity,
            'avg_price': self.avg_price
        }

class InvestmentTransaction(db.Model):
    __tablename__ = 'investment_transactions'

    id = db.Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    portfolio_id = db.Column(Uuid(as_uuid=True), db.ForeignKey('investment_portfolios.id'), nullable=False)
    type = db.Column(db.String(10), nullable=False) # 'BUY' or 'SELL'
    asset_code = db.Column(db.String(10), nullable=False)
    quantity = db.Column(db.Float, nullable=False)
    price = db.Column(db.Float, nullable=False)
    total_value = db.Column(db.Float, nullable=False)
    timestamp = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))

    def to_dict(self):
        return {
            'id': str(self.id),
            'type': self.type,
            'asset_code': self.asset_code,
            'quantity': self.quantity,
            'price': self.price,
            'total_value': self.total_value,
            'timestamp': self.timestamp.isoformat()
        }

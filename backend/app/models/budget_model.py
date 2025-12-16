from app.extensions import db
import uuid
import enum
from sqlalchemy import Enum, Uuid
from datetime import datetime, timezone

class BudgetCategory(enum.Enum):
    FOOD = "makanan"
    TRANSPORT = "transportasi"
    SHOPPING = "belanja"
    ENTERTAINMENT = "hiburan"
    BILLS = "tagihan"
    OTHERS = "lainnya"

class Budget(db.Model):
    __tablename__ = 'budgets'

    id = db.Column(Uuid(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = db.Column(Uuid(as_uuid=True), db.ForeignKey('users.id'), nullable=False)
    category = db.Column(db.String(50), nullable=True) 
    category_id = db.Column(Uuid(as_uuid=True), db.ForeignKey('categories.id'), nullable=True)
    name = db.Column(db.Text, nullable=True)
    amount = db.Column(db.Numeric(15, 2), nullable=False)
    period = db.Column(db.String(20), nullable=True)
    start_date = db.Column(db.Date, nullable=True)
    end_date = db.Column(db.Date, nullable=True)
    alert_threshold = db.Column(db.Integer, default=80)
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))

    user = db.relationship('User', backref='budgets')
    # category_rel = db.relationship('Category') # If we want to link to Category model
    # Actually, user request mentioned "Set budget per kategori".
    # Let's use String for category to match Transaction description or a specific category field if it exists.
    # Transaction model has 'description', but not 'category'.
    # Wait, Transaction model:
    # description = db.Column(db.String(100), nullable=False)
    # transaction_type = db.Column(ENUM(TransactionType), nullable=False)
    # It seems transactions don't have a 'category' column yet?
    # The user request says "Set budget per kategori".
    # If transactions don't have categories, how do we monitor budget vs actual spending?
    # Maybe 'description' is used as category? Or we need to add 'category' to Transaction?
    # Let's check Transaction model again.
    
    amount = db.Column(db.Integer, nullable=False) # Budget limit
    period = db.Column(db.String(20), default="monthly") # monthly, weekly
    created_at = db.Column(db.TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
    updated_at = db.Column(db.TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc), nullable=False)
    
    user = db.relationship('User', back_populates='budgets')

    def to_dict(self):
        return {
            'id': str(self.id),
            'user_id': str(self.user_id),
            'category': self.category,
            'amount': self.amount,
            'period': self.period,
            'created_at': self.created_at,
            'updated_at': self.updated_at
        }

"""Add investment tables to supabase

Revision ID: f50e2eb8b106
Revises: 
Create Date: 2025-12-10 19:32:58.020214

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = 'f50e2eb8b106'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    # Drop existing investment tables to ensure clean state (and correct types)
    op.execute("DROP TABLE IF EXISTS investment_transactions CASCADE")
    op.execute("DROP TABLE IF EXISTS investment_assets CASCADE")
    op.execute("DROP TABLE IF EXISTS investment_portfolios CASCADE")

    # Create new investment tables
    op.create_table('investment_portfolios',
        sa.Column('id', sa.UUID(), nullable=False),
        sa.Column('user_id', sa.UUID(), nullable=False),
        sa.Column('virtual_cash', sa.Float(), nullable=True),
        sa.Column('xp', sa.Integer(), nullable=True),
        sa.Column('level', sa.Integer(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
        sa.PrimaryKeyConstraint('id'),
        sa.UniqueConstraint('user_id')
    )
    op.create_table('investment_assets',
        sa.Column('id', sa.UUID(), nullable=False),
        sa.Column('portfolio_id', sa.UUID(), nullable=False),
        sa.Column('asset_code', sa.String(length=10), nullable=False),
        sa.Column('asset_name', sa.String(length=100), nullable=False),
        sa.Column('quantity', sa.Float(), nullable=True),
        sa.Column('avg_price', sa.Float(), nullable=True),
        sa.ForeignKeyConstraint(['portfolio_id'], ['investment_portfolios.id'], ),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_table('investment_transactions',
        sa.Column('id', sa.UUID(), nullable=False),
        sa.Column('portfolio_id', sa.UUID(), nullable=False),
        sa.Column('type', sa.String(length=10), nullable=False),
        sa.Column('asset_code', sa.String(length=10), nullable=False),
        sa.Column('quantity', sa.Float(), nullable=False),
        sa.Column('price', sa.Float(), nullable=False),
        sa.Column('total_value', sa.Float(), nullable=False),
        sa.Column('timestamp', sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(['portfolio_id'], ['investment_portfolios.id'], ),
        sa.PrimaryKeyConstraint('id')
    )

    # Alter existing tables (budgets, transactions) - ADD columns only, avoid drops for safety
    with op.batch_alter_table('budgets', schema=None) as batch_op:
        # Check if column exists before adding? Alembic doesn't do this easily.
        # But if we assume the user wants to sync, we try.
        # If it fails with "column already exists", we might need to handle that.
        # For now, let's assume they don't exist or we can ignore the error if they do?
        # No, better to let it fail and fix if needed, or use "IF NOT EXISTS" in SQL.
        # But batch_op doesn't support IF NOT EXISTS directly.
        # I'll leave it as is. If it fails, I'll know.
        batch_op.add_column(sa.Column('category', sa.String(length=50), nullable=True)) 
        pass

    with op.batch_alter_table('transactions', schema=None) as batch_op:
        # Create enum type first if it doesn't exist
        transaction_type = sa.Enum('DEPOSIT', 'WITHDRAWAL', name='transactiontype')
        transaction_type.create(op.get_bind(), checkfirst=True)
        
        batch_op.add_column(sa.Column('transaction_type', sa.Enum('DEPOSIT', 'WITHDRAWAL', name='transactiontype'), nullable=True))
        batch_op.add_column(sa.Column('total_price', sa.Float(), nullable=True))
        pass


def downgrade():
    pass

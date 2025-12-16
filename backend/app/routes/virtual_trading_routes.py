from flask import Blueprint, request, jsonify
from app.models.virtual_trading_model import VirtualPortfolio, VirtualPosition, VirtualTransaction
from app.extensions import db
from flask_jwt_extended import jwt_required, get_jwt_identity

virtual_trading_bp = Blueprint('virtual_trading', __name__)

@virtual_trading_bp.route('/portfolio', methods=['GET'])
@jwt_required()
def get_portfolio():
    current_user_id = get_jwt_identity()
    portfolio = VirtualPortfolio.query.filter_by(user_id=current_user_id).first()
    
    if not portfolio:
        # Create default portfolio
        portfolio = VirtualPortfolio(user_id=current_user_id)
        db.session.add(portfolio)
        db.session.commit()
        
    return jsonify({
        'id': portfolio.id,
        'current_balance': portfolio.current_balance,
        'total_profit_loss': portfolio.total_profit_loss,
        'initial_balance': portfolio.initial_balance
    }), 200

@virtual_trading_bp.route('/positions', methods=['GET'])
@jwt_required()
def get_positions():
    current_user_id = get_jwt_identity()
    portfolio = VirtualPortfolio.query.filter_by(user_id=current_user_id).first()
    
    if not portfolio:
        return jsonify([]), 200
        
    positions = VirtualPosition.query.filter_by(portfolio_id=portfolio.id, status='open').all()
    
    positions_data = []
    for pos in positions:
        positions_data.append({
            'id': pos.id,
            'asset_symbol': pos.asset_symbol,
            'asset_type': pos.asset_type,
            'quantity': pos.quantity,
            'entry_price': pos.entry_price,
            'current_price': pos.current_price,
            'profit_loss': pos.profit_loss
        })
        
    return jsonify(positions_data), 200

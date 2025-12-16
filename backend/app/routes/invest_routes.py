from flask import Blueprint, request, jsonify
from app.extensions import db
from app.models.investment_model import InvestmentPortfolio, InvestmentAsset, InvestmentTransaction
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import datetime, timezone

invest_bp = Blueprint('invest', __name__)

@invest_bp.route('/portfolio', methods=['GET'])
@jwt_required()
def get_portfolio():
    current_user_id = get_jwt_identity()
    portfolio = InvestmentPortfolio.query.filter_by(user_id=current_user_id).first()

    if not portfolio:
        # Create new portfolio if not exists
        portfolio = InvestmentPortfolio(user_id=current_user_id)
        db.session.add(portfolio)
        db.session.commit()

    return jsonify({
        "status": "success",
        "data": portfolio.to_dict()
    }), 200

@invest_bp.route('/buy', methods=['POST'])
@jwt_required()
def buy_asset():
    current_user_id = get_jwt_identity()
    data = request.get_json()
    
    asset_code = data.get('asset_code')
    asset_name = data.get('asset_name')
    quantity = float(data.get('quantity'))
    price = float(data.get('price'))
    
    if not all([asset_code, asset_name, quantity, price]):
        return jsonify({"message": "Missing required fields"}), 400

    portfolio = InvestmentPortfolio.query.filter_by(user_id=current_user_id).first()
    if not portfolio:
        return jsonify({"message": "Portfolio not found"}), 404

    total_cost = quantity * price
    if portfolio.virtual_cash < total_cost:
        return jsonify({"message": "Insufficient virtual cash"}), 400

    # Deduct cash
    portfolio.virtual_cash -= total_cost

    # Update or Create Asset
    asset = InvestmentAsset.query.filter_by(portfolio_id=portfolio.id, asset_code=asset_code).first()
    if asset:
        # Calculate new average price
        total_quantity = asset.quantity + quantity
        total_value = (asset.quantity * asset.avg_price) + total_cost
        asset.avg_price = total_value / total_quantity
        asset.quantity = total_quantity
    else:
        asset = InvestmentAsset(
            portfolio_id=portfolio.id,
            asset_code=asset_code,
            asset_name=asset_name,
            quantity=quantity,
            avg_price=price
        )
        db.session.add(asset)

    # Record Transaction
    transaction = InvestmentTransaction(
        portfolio_id=portfolio.id,
        type='BUY',
        asset_code=asset_code,
        quantity=quantity,
        price=price,
        total_value=total_cost
    )
    db.session.add(transaction)
    
    # Add XP (Example logic: 10 XP per buy)
    portfolio.xp += 10
    
    db.session.commit()

    return jsonify({
        "status": "success",
        "message": "Asset purchased successfully",
        "data": portfolio.to_dict()
    }), 200

@invest_bp.route('/sell', methods=['POST'])
@jwt_required()
def sell_asset():
    current_user_id = get_jwt_identity()
    data = request.get_json()
    
    asset_code = data.get('asset_code')
    quantity = float(data.get('quantity'))
    price = float(data.get('price'))
    
    if not all([asset_code, quantity, price]):
        return jsonify({"message": "Missing required fields"}), 400

    portfolio = InvestmentPortfolio.query.filter_by(user_id=current_user_id).first()
    if not portfolio:
        return jsonify({"message": "Portfolio not found"}), 404

    asset = InvestmentAsset.query.filter_by(portfolio_id=portfolio.id, asset_code=asset_code).first()
    if not asset or asset.quantity < quantity:
        return jsonify({"message": "Insufficient asset quantity"}), 400

    total_proceeds = quantity * price
    
    # Update Asset
    asset.quantity -= quantity
    if asset.quantity <= 0:
        db.session.delete(asset)
    
    # Add Cash
    portfolio.virtual_cash += total_proceeds

    # Record Transaction
    transaction = InvestmentTransaction(
        portfolio_id=portfolio.id,
        type='SELL',
        asset_code=asset_code,
        quantity=quantity,
        price=price,
        total_value=total_proceeds
    )
    db.session.add(transaction)
    
    db.session.commit()

    return jsonify({
        "status": "success",
        "message": "Asset sold successfully",
        "data": portfolio.to_dict()
    }), 200

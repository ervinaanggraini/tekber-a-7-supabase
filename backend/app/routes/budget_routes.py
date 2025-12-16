from flask import Blueprint, request, jsonify
from app.models.budget_model import Budget
from app.extensions import db
from flask_jwt_extended import jwt_required, get_jwt_identity
from sqlalchemy.exc import SQLAlchemyError

budget_bp = Blueprint('budget_bp', __name__)

@budget_bp.route('/', methods=['POST'])
@jwt_required()
def create_budget():
    try:
        current_user_id = get_jwt_identity()
        data = request.get_json()
        
        category = data.get('category')
        amount = data.get('amount')
        period = data.get('period', 'monthly')

        if not category or not amount:
            return jsonify({'error': 'Category and amount are required'}), 400

        # Check if budget for this category already exists
        existing_budget = Budget.query.filter_by(user_id=current_user_id, category=category).first()
        if existing_budget:
            return jsonify({'error': 'Budget for this category already exists'}), 400

        new_budget = Budget(
            user_id=current_user_id,
            category=category,
            amount=amount,
            period=period
        )

        db.session.add(new_budget)
        db.session.commit()

        return jsonify({'message': 'Budget created successfully', 'data': new_budget.to_dict()}), 201

    except SQLAlchemyError as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@budget_bp.route('/', methods=['GET'])
@jwt_required()
def get_budgets():
    try:
        current_user_id = get_jwt_identity()
        budgets = Budget.query.filter_by(user_id=current_user_id).all()
        return jsonify({'data': [budget.to_dict() for budget in budgets]}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@budget_bp.route('/<uuid:budget_id>', methods=['PUT'])
@jwt_required()
def update_budget(budget_id):
    try:
        current_user_id = get_jwt_identity()
        budget = Budget.query.filter_by(id=budget_id, user_id=current_user_id).first()

        if not budget:
            return jsonify({'error': 'Budget not found'}), 404

        data = request.get_json()
        
        if 'amount' in data:
            budget.amount = data['amount']
        if 'period' in data:
            budget.period = data['period']
        # Category usually shouldn't be changed, but if needed:
        if 'category' in data:
            # Check if new category already exists
            if data['category'] != budget.category:
                existing = Budget.query.filter_by(user_id=current_user_id, category=data['category']).first()
                if existing:
                    return jsonify({'error': 'Budget for this category already exists'}), 400
                budget.category = data['category']

        db.session.commit()
        return jsonify({'message': 'Budget updated successfully', 'data': budget.to_dict()}), 200

    except SQLAlchemyError as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@budget_bp.route('/<uuid:budget_id>', methods=['DELETE'])
@jwt_required()
def delete_budget(budget_id):
    try:
        current_user_id = get_jwt_identity()
        budget = Budget.query.filter_by(id=budget_id, user_id=current_user_id).first()

        if not budget:
            return jsonify({'error': 'Budget not found'}), 404

        db.session.delete(budget)
        db.session.commit()
        return jsonify({'message': 'Budget deleted successfully'}), 200

    except SQLAlchemyError as e:
        db.session.rollback()
        return jsonify({'error': str(e)}), 500
    except Exception as e:
        return jsonify({'error': str(e)}), 500

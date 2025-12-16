from flask import Blueprint, request, jsonify
from app.models.savings_model import SavingsGoal
from app.extensions import db
from flask_jwt_extended import jwt_required, get_jwt_identity
from datetime import datetime

savings_bp = Blueprint('savings', __name__)

@savings_bp.route('/', methods=['GET'])
@jwt_required()
def get_savings_goals():
    current_user_id = get_jwt_identity()
    goals = SavingsGoal.query.filter_by(user_id=current_user_id).all()
    
    goals_data = []
    for goal in goals:
        goals_data.append({
            'id': goal.id,
            'target_amount': goal.target_amount,
            'deadline': goal.deadline.isoformat() if goal.deadline else None,
            'created_at': goal.created_at
        })
        
    return jsonify(goals_data), 200

@savings_bp.route('/', methods=['POST'])
@jwt_required()
def create_savings_goal():
    current_user_id = get_jwt_identity()
    data = request.get_json()
    
    target_amount = data.get('target_amount')
    deadline_str = data.get('deadline')
    
    if not target_amount or not deadline_str:
        return jsonify({'message': 'Missing required fields'}), 400
        
    try:
        deadline = datetime.fromisoformat(deadline_str).date()
    except ValueError:
        return jsonify({'message': 'Invalid date format'}), 400
        
    new_goal = SavingsGoal(
        user_id=current_user_id,
        target_amount=target_amount,
        deadline=deadline
    )
    
    db.session.add(new_goal)
    db.session.commit()
    
    return jsonify({'message': 'Savings goal created successfully', 'id': new_goal.id}), 201

from flask import Blueprint, request, jsonify
from app.models.insights_model import FinancialInsight, SpendingPattern
from app.extensions import db
from flask_jwt_extended import jwt_required, get_jwt_identity

insights_bp = Blueprint('insights', __name__)

@insights_bp.route('/', methods=['GET'])
@jwt_required()
def get_insights():
    current_user_id = get_jwt_identity()
    insights = FinancialInsight.query.filter_by(user_id=current_user_id, is_dismissed=False).order_by(FinancialInsight.created_at.desc()).all()
    
    insights_data = []
    for insight in insights:
        insights_data.append({
            'id': insight.id,
            'type': insight.type,
            'title': insight.title,
            'content': insight.content,
            'priority': insight.priority,
            'is_read': insight.is_read,
            'created_at': insight.created_at
        })
        
    return jsonify(insights_data), 200

@insights_bp.route('/spending-patterns', methods=['GET'])
@jwt_required()
def get_spending_patterns():
    current_user_id = get_jwt_identity()
    # Get latest monthly pattern
    pattern = SpendingPattern.query.filter_by(user_id=current_user_id, period_type='monthly').order_by(SpendingPattern.period_start.desc()).first()
    
    if not pattern:
        return jsonify({'message': 'No spending pattern data available'}), 404
        
    return jsonify({
        'period_start': pattern.period_start,
        'period_end': pattern.period_end,
        'total_income': pattern.total_income,
        'total_expense': pattern.total_expense,
        'net_savings': pattern.net_savings,
        'top_categories': pattern.top_categories,
        'ai_summary': pattern.ai_summary
    }), 200

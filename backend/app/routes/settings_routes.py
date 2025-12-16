from flask import Blueprint, request, jsonify
from app.models.settings_model import UserSettings
from app.extensions import db
from flask_jwt_extended import jwt_required, get_jwt_identity

settings_bp = Blueprint('settings', __name__)

@settings_bp.route('/', methods=['GET'])
@jwt_required()
def get_settings():
    current_user_id = get_jwt_identity()
    settings = UserSettings.query.filter_by(user_id=current_user_id).first()
    
    if not settings:
        # Create default settings if not exist
        settings = UserSettings(user_id=current_user_id)
        db.session.add(settings)
        db.session.commit()
        
    return jsonify({
        'enable_notifications': settings.enable_notifications,
        'enable_daily_reminders': settings.enable_daily_reminders,
        'enable_mission_alerts': settings.enable_mission_alerts,
        'enable_budget_alerts': settings.enable_budget_alerts,
        'currency': settings.currency,
        'language': settings.language,
        'theme': settings.theme,
        'enable_ai_insights': settings.enable_ai_insights
    }), 200

@settings_bp.route('/', methods=['PUT'])
@jwt_required()
def update_settings():
    current_user_id = get_jwt_identity()
    settings = UserSettings.query.filter_by(user_id=current_user_id).first()
    
    if not settings:
        return jsonify({'message': 'Settings not found'}), 404
        
    data = request.get_json()
    
    if 'enable_notifications' in data:
        settings.enable_notifications = data['enable_notifications']
    if 'enable_daily_reminders' in data:
        settings.enable_daily_reminders = data['enable_daily_reminders']
    if 'currency' in data:
        settings.currency = data['currency']
    if 'theme' in data:
        settings.theme = data['theme']
        
    db.session.commit()
    
    return jsonify({'message': 'Settings updated successfully'}), 200

from flask import Blueprint, request, jsonify
from app.models.gamification_model import UserProfile, Badge, UserBadge, Mission, UserMission
from app.extensions import db
from flask_jwt_extended import jwt_required, get_jwt_identity
from sqlalchemy import Uuid
import uuid

gamification_bp = Blueprint('gamification', __name__)

@gamification_bp.route('/profile', methods=['GET'])
@jwt_required()
def get_profile():
    current_user_id = get_jwt_identity()
    profile = UserProfile.query.filter_by(id=current_user_id).first()
    
    if not profile:
        return jsonify({'message': 'Profile not found'}), 404
        
    return jsonify({
        'full_name': profile.full_name,
        'level': profile.level,
        'total_xp': profile.total_xp,
        'total_points': profile.total_points,
        'current_streak': profile.current_streak,
        'risk_profile': profile.risk_profile
    }), 200

@gamification_bp.route('/badges', methods=['GET'])
@jwt_required()
def get_badges():
    current_user_id = get_jwt_identity()
    user_badges = UserBadge.query.filter_by(user_id=current_user_id).all()
    
    badges_data = []
    for ub in user_badges:
        badges_data.append({
            'name': ub.badge.name,
            'description': ub.badge.description,
            'icon': ub.badge.icon,
            'earned_at': ub.earned_at
        })
        
    return jsonify(badges_data), 200

@gamification_bp.route('/missions', methods=['GET'])
@jwt_required()
def get_missions():
    current_user_id = get_jwt_identity()
    # Get active missions for user
    user_missions = UserMission.query.filter_by(user_id=current_user_id, status='in_progress').all()
    
    missions_data = []
    for um in user_missions:
        missions_data.append({
            'id': um.mission.id,
            'title': um.mission.title,
            'description': um.mission.description,
            'current_progress': um.current_progress,
            'target_progress': um.target_progress,
            'xp_reward': um.mission.xp_reward,
            'points_reward': um.mission.points_reward
        })
        
    return jsonify(missions_data), 200

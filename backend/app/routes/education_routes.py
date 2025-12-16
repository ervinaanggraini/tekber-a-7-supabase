from flask import Blueprint, request, jsonify
from app.models.education_model import Course, UserCourseProgress
from app.extensions import db
from flask_jwt_extended import jwt_required, get_jwt_identity

education_bp = Blueprint('education', __name__)

@education_bp.route('/courses', methods=['GET'])
@jwt_required()
def get_courses():
    courses = Course.query.filter_by(is_published=True).order_by(Course.order_index).all()
    
    courses_data = []
    for course in courses:
        courses_data.append({
            'id': course.id,
            'title': course.title,
            'description': course.description,
            'level': course.level,
            'category': course.category,
            'thumbnail_url': course.thumbnail_url,
            'duration_minutes': course.duration_minutes,
            'xp_reward': course.xp_reward
        })
        
    return jsonify(courses_data), 200

@education_bp.route('/courses/<course_id>/progress', methods=['GET'])
@jwt_required()
def get_course_progress(course_id):
    current_user_id = get_jwt_identity()
    progress = UserCourseProgress.query.filter_by(user_id=current_user_id, course_id=course_id).first()
    
    if not progress:
        return jsonify({'read_articles': [], 'total_articles_read': 0}), 200
        
    return jsonify({
        'read_articles': progress.read_articles,
        'total_articles_read': progress.total_articles_read
    }), 200

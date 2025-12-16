import os
from flask import Flask
from dotenv import load_dotenv
from app.routes.user_routes import user_bp
from app.routes.transaction_routes import transaction_bp
from app.routes.budget_routes import budget_bp
from app.extensions import db,migrate
from flask_jwt_extended import JWTManager
from flask_cors import CORS

jwt = JWTManager()

def create_app():
    load_dotenv()

    app = Flask(__name__)
    CORS(app) # Enable CORS for all routes

    # database
    db_engine = os.getenv('DB_ENGINE', 'postgresql')

    if db_engine == 'sqlite':
        app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///moneyvesto.db'
    else:
        user = os.getenv('DB_USER')
        password = os.getenv('DB_PASSWORD')
        host = os.getenv('DB_HOST')
        port = os.getenv('DB_PORT')
        dbname = os.getenv('DB_NAME')
        app.config['SQLALCHEMY_DATABASE_URI'] = f'postgresql://{user}:{password}@{host}:{port}/{dbname}'
    
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    #JWT
    app.config['JWT_SECRET_KEY'] = os.getenv('JWT_SECRET_KEY')

    #init
    db.init_app(app)
    migrate.init_app(app,db=db)
    jwt.init_app(app)

    # Import models to ensure they are registered with SQLAlchemy
    from app.models.user_model import User
    from app.models.transaction_model import Transaction
    from app.models.budget_model import Budget
    from app.models.investment_model import InvestmentPortfolio, InvestmentAsset, InvestmentTransaction
    from app.models.gamification_model import UserProfile, Badge, UserBadge, Mission, UserMission
    from app.models.savings_model import SavingsGoal
    from app.models.education_model import Course, UserCourseProgress
    from app.models.insights_model import FinancialInsight, SpendingPattern, Category
    from app.models.settings_model import UserSettings
    from app.models.chat_model import ChatConversation, ChatMessage
    from app.models.virtual_trading_model import VirtualPortfolio, VirtualPosition, VirtualTransaction, InvestmentChallenge, UserInvestmentChallenge

    #Registering routes
    app.register_blueprint(user_bp, url_prefix='/api/users')
    app.register_blueprint(transaction_bp, url_prefix='/api/transactions')
    app.register_blueprint(budget_bp, url_prefix='/api/budgets')
    
    from app.routes.invest_routes import invest_bp
    app.register_blueprint(invest_bp, url_prefix='/api/invest')

    return app
    app.register_blueprint(budget_bp, url_prefix='/api/budgets')
    from app.routes.invest_routes import invest_bp
    app.register_blueprint(invest_bp, url_prefix='/api/invest')

    from app.routes.gamification_routes import gamification_bp
    app.register_blueprint(gamification_bp, url_prefix='/api/gamification')

    from app.routes.education_routes import education_bp
    app.register_blueprint(education_bp, url_prefix='/api/education')

    from app.routes.insights_routes import insights_bp
    app.register_blueprint(insights_bp, url_prefix='/api/insights')

    from app.routes.savings_routes import savings_bp
    app.register_blueprint(savings_bp, url_prefix='/api/savings')

    from app.routes.settings_routes import settings_bp
    app.register_blueprint(settings_bp, url_prefix='/api/settings')

    from app.routes.virtual_trading_routes import virtual_trading_bp
    app.register_blueprint(virtual_trading_bp, url_prefix='/api/virtual-trading')

    with app.app_context():
        db.create_all()

    return app

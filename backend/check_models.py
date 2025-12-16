from app import create_app, db
from app.models.investment_model import InvestmentPortfolio

app = create_app()

with app.app_context():
    print("Registered Tables:")
    print(db.metadata.tables.keys())
    
    print("\nChecking if InvestmentPortfolio is mapped:")
    try:
        print(InvestmentPortfolio.__table__)
    except Exception as e:
        print(e)

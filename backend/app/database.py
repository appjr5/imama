import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

# Set this to your actual Postgres connection string, e.g.:
# postgresql://imama_user:yourpassword@localhost:5432/imama_db
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://imama_user:changeme@localhost:5432/imama_db")

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

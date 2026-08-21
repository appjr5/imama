from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from datetime import datetime
from .database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    phone = Column(String, default="")
    pregnancy_weeks = Column(Integer, default=0)
    due_date = Column(String, default="")
    weight_kg = Column(Float, default=0)
    height_cm = Column(Float, default=0)
    number_of_kids = Column(Integer, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)

    messages = relationship("ChatMessageRecord", back_populates="user")


class ChatMessageRecord(Base):
    __tablename__ = "chat_messages"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    message = Column(Text, nullable=False)
    reply = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="messages")


class BlogPostRecord(Base):
    __tablename__ = "blog_posts"

    id = Column(Integer, primary_key=True, index=True)
    date = Column(String, nullable=False)
    title = Column(String, nullable=False)
    body = Column(Text, nullable=False)
    category = Column(String, default="jumla")

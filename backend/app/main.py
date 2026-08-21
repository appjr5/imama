import os
from datetime import datetime
from dotenv import load_dotenv

load_dotenv()

from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from pydantic import BaseModel
import httpx

from .database import Base, engine, get_db
from .models import User, ChatMessageRecord, BlogPostRecord
from .auth import hash_password, verify_password, create_token, get_current_user

Base.metadata.create_all(bind=engine)

app = FastAPI(title="iMama API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # tighten this before real production use
    allow_methods=["*"],
    allow_headers=["*"],
)


# ---------- Schemas ----------

class RegisterRequest(BaseModel):
    name: str
    email: str
    password: str
    phone: str = ""
    pregnancy_weeks: int = 0
    due_date: str = ""
    weight_kg: float = 0
    height_cm: float = 0
    number_of_kids: int = 0


class LoginRequest(BaseModel):
    email: str
    password: str


class ProfileUpdate(BaseModel):
    name: str
    phone: str = ""
    pregnancyWeeks: int = 0
    dueDate: str = ""
    weightKg: float = 0
    heightCm: float = 0
    numberOfKids: int = 0


class ChatRequest(BaseModel):
    message: str
    user_id: str | None = None


# ---------- Auth ----------

@app.post("/auth/register")
def register(payload: RegisterRequest, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.email == payload.email).first()
    if existing:
        raise HTTPException(status_code=400, detail="Barua pepe tayari imesajiliwa.")

    user = User(
        name=payload.name,
        email=payload.email,
        password_hash=hash_password(payload.password),
        phone=payload.phone,
        pregnancy_weeks=payload.pregnancy_weeks,
        due_date=payload.due_date,
        weight_kg=payload.weight_kg,
        height_cm=payload.height_cm,
        number_of_kids=payload.number_of_kids,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    token = create_token(user.id)
    return {"token": token, "user_id": user.id}


@app.post("/auth/login")
def login(payload: LoginRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == payload.email).first()
    if not user or not verify_password(payload.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Barua pepe au nenosiri sio sahihi.")

    token = create_token(user.id)
    return {"token": token, "user_id": user.id}


# ---------- Profile ----------

@app.get("/profile")
def get_profile(current_user: User = Depends(get_current_user)):
    return {
        "name": current_user.name,
        "phone": current_user.phone,
        "pregnancy_weeks": current_user.pregnancy_weeks,
        "due_date": current_user.due_date,
        "weight_kg": current_user.weight_kg,
        "height_cm": current_user.height_cm,
        "number_of_kids": current_user.number_of_kids,
    }


@app.put("/profile")
def update_profile(
    payload: ProfileUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    current_user.name = payload.name
    current_user.phone = payload.phone
    current_user.pregnancy_weeks = payload.pregnancyWeeks
    current_user.due_date = payload.dueDate
    current_user.weight_kg = payload.weightKg
    current_user.height_cm = payload.heightCm
    current_user.number_of_kids = payload.numberOfKids
    db.commit()
    return {"status": "ok"}


# ---------- Chat ----------
# Calls Google AI Studio's Gemma API. Swap this for your own hosted
# Swahili Gemma backend if you have one — the contract the Flutter app
# expects is just: POST /chat -> {"reply": "..."}

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
GEMMA_MODEL = "gemma-3-27b-it"

@app.post("/chat")
async def chat(
    payload: ChatRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if not GEMINI_API_KEY:
        raise HTTPException(status_code=500, detail="GEMINI_API_KEY haijawekwa kwenye seva.")

    url = f"https://generativelanguage.googleapis.com/v1beta/models/{GEMMA_MODEL}:generateContent?key={GEMINI_API_KEY}"
    body = {
        "contents": [{"role": "user", "parts": [{"text": payload.message}]}],
        "systemInstruction": {
            "parts": [{
                "text": "Wewe ni msaidizi wa afya wa mama wajawazito anayeongea Kiswahili pekee. "
                        "Toa majibu rahisi, sahihi, na yenye huruma. Usitoe ushauri wa dharura wa "
                        "kitabibu unaohitaji daktari — mshauri mtumiaji kuwasiliana na mtoa huduma "
                        "wa afya kwa dalili kali au za dharura."
            }]
        },
    }

    async with httpx.AsyncClient(timeout=60) as client:
        response = await client.post(url, json=body)

    if response.status_code != 200:
        raise HTTPException(status_code=502, detail=f"Hitilafu kutoka kwa modeli: {response.text}")

    data = response.json()
    reply = data["candidates"][0]["content"]["parts"][0]["text"]

    record = ChatMessageRecord(user_id=current_user.id, message=payload.message, reply=reply)
    db.add(record)
    db.commit()

    return {"reply": reply}


# ---------- Blog ----------

@app.get("/blog")
def get_blog(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    posts = db.query(BlogPostRecord).order_by(BlogPostRecord.date.desc()).limit(14).all()
    return [
        {"date": p.date, "title": p.title, "body": p.body, "category": p.category}
        for p in posts
    ]


@app.get("/health")
def health():
    return {"status": "ok", "time": datetime.utcnow().isoformat()}

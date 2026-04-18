from __future__ import annotations
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from database import supabase
from typing import Optional

router = APIRouter(prefix="/reviews", tags=["reviews"])


class CreateReviewBody(BaseModel):
    rally_id: str
    user_id: str
    stars: int
    text: Optional[str] = None


@router.post("/")
def create_review(body: CreateReviewBody):
    if not 1 <= body.stars <= 5:
        raise HTTPException(status_code=400, detail="Stars debe ser entre 1 y 5")
    res = supabase.table("reviews").insert(body.model_dump()).execute()
    return res.data[0]

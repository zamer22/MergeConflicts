from __future__ import annotations
from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel
from database import supabase
from datetime import datetime
from typing import Optional

router = APIRouter(prefix="/rallies", tags=["rallies"])


class CreateRallyBody(BaseModel):
    title: str
    description: Optional[str] = None
    venue_id: Optional[str] = None
    creator_id: str
    entry_fee: int = 20
    max_participants: int = 20
    starts_at: datetime
    expires_at: datetime
    lat: float
    lng: float
    category: Optional[str] = "otro"
    tags: Optional[list[str]] = []
    image_url: Optional[str] = None


@router.get("/")
def get_active_rallies(
    category: Optional[str] = Query(None),
    search: Optional[str] = Query(None),
    status: Optional[str] = Query(None),  # "live" | "soon" | None = todos
):
    now = datetime.utcnow().isoformat()
    q = (
        supabase.table("rallies")
        .select("*, venues(name, address)")
        .eq("status", "active")
        .gt("expires_at", now)
        .order("expires_at", desc=False)
    )
    if category:
        q = q.eq("category", category)
    if search:
        q = q.ilike("title", f"%{search}%")

    res = q.execute()
    rallies = res.data

    if status == "live":
        rallies = [r for r in rallies if r["starts_at"] <= now]
    elif status == "soon":
        rallies = [r for r in rallies if r["starts_at"] > now]

    return rallies


@router.get("/categories")
def get_categories():
    return [
        {"key": "musica",   "label": "Música",   "icon": "🎵"},
        {"key": "feria",    "label": "Feria",     "icon": "🎪"},
        {"key": "arte",     "label": "Arte",      "icon": "🎨"},
        {"key": "comida",   "label": "Comida",    "icon": "🍴"},
        {"key": "deporte",  "label": "Deporte",   "icon": "🏃"},
        {"key": "mercado",  "label": "Mercado",   "icon": "🛒"},
        {"key": "taller",   "label": "Taller",    "icon": "📚"},
        {"key": "bar",      "label": "Bar",       "icon": "🍺"},
        {"key": "gym",      "label": "Gym",       "icon": "💪"},
        {"key": "otro",     "label": "Otro",      "icon": "✨"},
    ]


@router.get("/{rally_id}")
def get_rally(rally_id: str):
    res = supabase.table("rallies").select("*").eq("id", rally_id).single().execute()
    if not res.data:
        raise HTTPException(status_code=404, detail="Rally no encontrado")
    return res.data


@router.post("/")
def create_rally(body: CreateRallyBody):
    data = body.model_dump()
    data["starts_at"] = data["starts_at"].isoformat()
    data["expires_at"] = data["expires_at"].isoformat()
    res = supabase.table("rallies").insert(data).execute()
    return res.data[0]


@router.get("/{rally_id}/participants")
def get_participants(rally_id: str):
    res = (
        supabase.table("rally_participants")
        .select("*")
        .eq("rally_id", rally_id)
        .is_("cancelled_at", "null")
        .execute()
    )
    return res.data


@router.get("/{rally_id}/reviews")
def get_reviews(rally_id: str):
    res = (
        supabase.table("reviews")
        .select("*, users(username, avatar_url)")
        .eq("rally_id", rally_id)
        .order("created_at", desc=True)
        .execute()
    )
    return res.data


@router.get("/{rally_id}/stats")
def get_rally_stats(rally_id: str):
    participants = (
        supabase.table("rally_participants")
        .select("id", count="exact")
        .eq("rally_id", rally_id)
        .is_("cancelled_at", "null")
        .execute()
    )
    reviews = (
        supabase.table("reviews")
        .select("stars")
        .eq("rally_id", rally_id)
        .execute()
    )
    stars = [r["stars"] for r in reviews.data]
    avg = round(sum(stars) / len(stars), 1) if stars else None
    return {
        "participants": participants.count or 0,
        "reviews_count": len(stars),
        "avg_rating": avg,
    }

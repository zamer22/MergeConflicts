from __future__ import annotations
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from database import supabase
from datetime import datetime
from typing import Optional

router = APIRouter(prefix="/users", tags=["users"])


class CreateUserBody(BaseModel):
    id: str
    email: str
    username: str
    interests: Optional[list[str]] = []
    location_label: Optional[str] = None


class UpdateUserBody(BaseModel):
    bio: Optional[str] = None
    interests: Optional[list[str]] = None
    location_label: Optional[str] = None
    avatar_url: Optional[str] = None


@router.post("/")
def create_user(body: CreateUserBody):
    res = supabase.table("users").insert(body.model_dump()).execute()
    return res.data[0]


@router.get("/{user_id}")
def get_user(user_id: str):
    res = supabase.table("users").select("*").eq("id", user_id).limit(1).execute()
    if not res.data:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return res.data[0]


@router.patch("/{user_id}")
def update_user(user_id: str, body: UpdateUserBody):
    data = {k: v for k, v in body.model_dump().items() if v is not None}
    res = supabase.table("users").update(data).eq("id", user_id).execute()
    return res.data[0]


@router.get("/{user_id}/rallies")
def get_user_rallies(user_id: str):
    participations = (
        supabase.table("rally_participants")
        .select("rally_id")
        .eq("user_id", user_id)
        .eq("payment_status", "paid")
        .is_("cancelled_at", "null")
        .execute()
    )
    rally_ids = [p["rally_id"] for p in participations.data]
    if not rally_ids:
        return []
    return supabase.table("rallies").select("*").in_("id", rally_ids).execute().data


@router.get("/{user_id}/upcoming")
def get_upcoming(user_id: str):
    now = datetime.utcnow().isoformat()
    participations = (
        supabase.table("rally_participants")
        .select("rally_id")
        .eq("user_id", user_id)
        .eq("payment_status", "paid")
        .is_("cancelled_at", "null")
        .execute()
    )
    rally_ids = [p["rally_id"] for p in participations.data]
    if not rally_ids:
        return []
    return (
        supabase.table("rallies")
        .select("*")
        .in_("id", rally_ids)
        .gt("expires_at", now)
        .order("starts_at", desc=False)
        .execute()
        .data
    )


@router.get("/{user_id}/past")
def get_past(user_id: str):
    now = datetime.utcnow().isoformat()
    participations = (
        supabase.table("rally_participants")
        .select("rally_id")
        .eq("user_id", user_id)
        .eq("payment_status", "paid")
        .is_("cancelled_at", "null")
        .execute()
    )
    rally_ids = [p["rally_id"] for p in participations.data]
    if not rally_ids:
        return []
    return (
        supabase.table("rallies")
        .select("*")
        .in_("id", rally_ids)
        .lte("expires_at", now)
        .order("expires_at", desc=True)
        .execute()
        .data
    )


@router.get("/{user_id}/created")
def get_created(user_id: str):
    return (
        supabase.table("rallies")
        .select("*")
        .eq("creator_id", user_id)
        .order("created_at", desc=True)
        .execute()
        .data
    )


@router.get("/{user_id}/recommendations")
def get_recommendations(user_id: str):
    user_res = supabase.table("users").select("interests").eq("id", user_id).limit(1).execute()
    interests = user_res.data[0].get("interests") or [] if user_res.data else []

    now = datetime.utcnow().isoformat()
    q = (
        supabase.table("rallies")
        .select("*")
        .eq("status", "active")
        .gt("expires_at", now)
        .order("expires_at", desc=False)
        .limit(10)
    )
    if interests:
        q = q.in_("category", interests)

    rallies = q.execute().data
    return {
        "rallies": rallies,
        "reason": f"Basado en tus intereses: {', '.join(interests)}" if interests else "Eventos populares cerca de ti",
    }

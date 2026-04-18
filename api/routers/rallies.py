from __future__ import annotations
from fastapi import APIRouter, HTTPException
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


@router.get("/")
def get_active_rallies():
    now = datetime.utcnow().isoformat()
    res = (
        supabase.table("rallies")
        .select("*")
        .eq("status", "active")
        .gt("expires_at", now)
        .order("expires_at", desc=False)
        .execute()
    )
    return res.data


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

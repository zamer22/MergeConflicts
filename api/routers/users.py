from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from database import supabase

router = APIRouter(prefix="/users", tags=["users"])


class CreateUserBody(BaseModel):
    id: str
    email: str
    username: str


@router.post("/")
def create_user(body: CreateUserBody):
    res = supabase.table("users").insert(body.model_dump()).execute()
    return res.data[0]


@router.get("/{user_id}")
def get_user(user_id: str):
    res = supabase.table("users").select("*").eq("id", user_id).single().execute()
    if not res.data:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return res.data


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

    rallies = (
        supabase.table("rallies")
        .select("*")
        .in_("id", rally_ids)
        .execute()
    )
    return rallies.data

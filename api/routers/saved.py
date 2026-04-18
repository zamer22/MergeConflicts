from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from database import supabase

router = APIRouter(prefix="/saved", tags=["saved"])


class SaveBody(BaseModel):
    rally_id: str
    user_id: str


@router.post("/")
def save_event(body: SaveBody):
    res = supabase.table("saved_events").insert(body.model_dump()).execute()
    return res.data[0]


@router.delete("/")
def unsave_event(rally_id: str, user_id: str):
    supabase.table("saved_events").delete().eq("rally_id", rally_id).eq("user_id", user_id).execute()
    return {"unsaved": True}


@router.get("/{user_id}")
def get_saved(user_id: str):
    saved = supabase.table("saved_events").select("rally_id").eq("user_id", user_id).execute()
    rally_ids = [s["rally_id"] for s in saved.data]
    if not rally_ids:
        return []
    return supabase.table("rallies").select("*").in_("id", rally_ids).execute().data

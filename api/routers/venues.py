from fastapi import APIRouter, HTTPException
from database import supabase

router = APIRouter(prefix="/venues", tags=["venues"])


@router.get("/")
def get_venues():
    res = supabase.table("venues").select("*").execute()
    return res.data


@router.get("/{venue_id}")
def get_venue(venue_id: str):
    res = supabase.table("venues").select("*").eq("id", venue_id).single().execute()
    if not res.data:
        raise HTTPException(status_code=404, detail="Venue no encontrado")
    return res.data

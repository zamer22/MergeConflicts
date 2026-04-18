from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from database import supabase
from datetime import datetime

router = APIRouter(prefix="/participants", tags=["participants"])


class JoinRallyBody(BaseModel):
    rally_id: str
    user_id: str


class CancelBody(BaseModel):
    rally_id: str
    user_id: str


@router.post("/join")
def join_rally(body: JoinRallyBody):
    # Verificar que el rally existe y tiene cupo
    rally_res = (
        supabase.table("rallies")
        .select("max_participants, status, expires_at")
        .eq("id", body.rally_id)
        .single()
        .execute()
    )
    if not rally_res.data:
        raise HTTPException(status_code=404, detail="Rally no encontrado")

    rally = rally_res.data
    if rally["status"] != "active":
        raise HTTPException(status_code=400, detail="El rally ya no está activo")
    if datetime.fromisoformat(rally["expires_at"]) < datetime.utcnow():
        raise HTTPException(status_code=400, detail="El rally ya expiró")

    # Contar participantes actuales
    count_res = (
        supabase.table("rally_participants")
        .select("id", count="exact")
        .eq("rally_id", body.rally_id)
        .is_("cancelled_at", "null")
        .execute()
    )
    current = count_res.count or 0
    if current >= rally["max_participants"]:
        raise HTTPException(status_code=400, detail="El rally está lleno")

    # Insertar participante con pago mockeado como 'paid'
    entry = {
        "rally_id": body.rally_id,
        "user_id": body.user_id,
        "payment_status": "paid",
    }
    res = supabase.table("rally_participants").insert(entry).execute()
    return res.data[0]


@router.post("/cancel")
def cancel_participation(body: CancelBody):
    res = (
        supabase.table("rally_participants")
        .update({"cancelled_at": datetime.utcnow().isoformat()})
        .eq("rally_id", body.rally_id)
        .eq("user_id", body.user_id)
        .is_("cancelled_at", "null")
        .execute()
    )
    if not res.data:
        raise HTTPException(status_code=404, detail="Participación no encontrada")
    return {"cancelled": True}

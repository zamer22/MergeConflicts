from __future__ import annotations
import os
from fastapi import APIRouter, HTTPException
from database import supabase

router = APIRouter(prefix="/ai", tags=["ai"])


def _gemini_model():
    try:
        import google.generativeai as genai
        key = os.environ.get("GEMINI_API_KEY")
        if not key:
            return None
        genai.configure(api_key=key)
        return genai.GenerativeModel("gemini-1.5-flash")
    except ImportError:
        return None


def _ask(model, prompt: str) -> str:
    response = model.generate_content(prompt)
    return response.text.strip()


@router.get("/summary/{rally_id}")
def get_ai_summary(rally_id: str):
    res = supabase.table("reviews").select("stars, text").eq("rally_id", rally_id).execute()
    reviews = [r for r in res.data if r.get("text")]

    if not res.data:
        raise HTTPException(status_code=404, detail="No hay reseñas para este rally")

    model = _gemini_model()

    if not model or not reviews:
        avg = round(sum(r["stars"] for r in res.data) / len(res.data), 1)
        return {
            "summary": f"Los asistentes califican este evento con {avg}/5 estrellas. ¡Vale la pena visitarlo!",
            "tags": ["+ buena vibe", "+ recomendado"],
        }

    review_text = "\n".join([f"- {r['stars']}★: {r['text']}" for r in reviews[:10]])

    prompt = (
        "Resume estas reseñas de un evento social en 1-2 oraciones en español. "
        "Sé específico y útil para alguien que decide si ir.\n\n"
        f"Reseñas:\n{review_text}\n\n"
        "Responde exactamente en este formato:\n"
        "RESUMEN: [1-2 oraciones]\n"
        "ETIQUETAS: [2-3 etiquetas cortas, ej: + buen ambiente, - lleno, + música]"
    )

    text = _ask(model, prompt)
    summary, tags = "", []
    for line in text.split("\n"):
        if line.startswith("RESUMEN:"):
            summary = line.replace("RESUMEN:", "").strip()
        elif line.startswith("ETIQUETAS:"):
            tags = [t.strip() for t in line.replace("ETIQUETAS:", "").split(",")]

    return {"summary": summary or text, "tags": tags}


@router.get("/recommendations/{user_id}")
def get_ai_recommendations(user_id: str):
    from datetime import datetime

    user_res = (
        supabase.table("users")
        .select("interests, username")
        .eq("id", user_id)
        .limit(1)
        .execute()
    )
    user_data = user_res.data[0] if user_res.data else {}
    interests = user_data.get("interests") or []
    username = user_data.get("username", "usuario")
    now = datetime.utcnow().isoformat()

    rallies = (
        supabase.table("rallies")
        .select("id, title, category, tags, entry_fee, starts_at")
        .eq("status", "active")
        .gt("expires_at", now)
        .order("expires_at", desc=False)
        .limit(20)
        .execute()
        .data
    )

    if not rallies:
        return {"rallies": [], "reason": "No hay rallies activos ahora mismo"}

    model = _gemini_model()

    if not model:
        filtered = (
            [r for r in rallies if r.get("category") in interests] if interests else rallies
        )[:5]
        reason = (
            f"Basado en tus intereses: {', '.join(interests)}"
            if interests
            else "Populares cerca de ti"
        )
        full = (
            supabase.table("rallies")
            .select("*")
            .in_("id", [r["id"] for r in filtered])
            .execute()
            .data
        )
        return {"rallies": full, "reason": reason}

    rallies_text = "\n".join([
        f"- ID:{r['id']} | {r['title']} | {r['category']} | ${r['entry_fee']} | tags:{r.get('tags', [])}"
        for r in rallies
    ])

    prompt = (
        f"Eres un sistema de recomendación para Drop, app de eventos espontáneos.\n"
        f"Usuario: {username}\nIntereses: {', '.join(interests)}\n\n"
        f"Rallies disponibles:\n{rallies_text}\n\n"
        "Selecciona los 3-5 mejores rallies para este usuario y explica en una oración en español.\n"
        "Responde exactamente en este formato:\n"
        "IDS: id1,id2,id3\n"
        "RAZÓN: [1 oración]"
    )

    text = _ask(model, prompt)
    selected_ids, reason = [], f"Seleccionados para {username}"
    for line in text.split("\n"):
        if line.startswith("IDS:"):
            selected_ids = [i.strip() for i in line.replace("IDS:", "").split(",")]
        elif line.startswith("RAZÓN:"):
            reason = line.replace("RAZÓN:", "").strip()

    if not selected_ids:
        selected_ids = [r["id"] for r in rallies[:5]]

    full = (
        supabase.table("rallies")
        .select("*")
        .in_("id", selected_ids)
        .execute()
        .data
    )
    return {"rallies": full, "reason": reason}

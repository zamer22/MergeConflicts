"""Seed via FastAPI endpoints (avoids RLS)"""
import requests
from datetime import datetime, timedelta, timezone
import uuid, json

BASE = "http://localhost:8000"
now = datetime.now(timezone.utc)

def ts(delta_h=0, delta_m=0):
    return (now + timedelta(hours=delta_h, minutes=delta_m)).strftime("%Y-%m-%dT%H:%M:%S")

# --- Get existing venues ---
venues_raw = requests.get(f"{BASE}/venues/").json()
# Use first set (no duplicates)
seen = set()
venues = []
for v in venues_raw:
    if v["name"] not in seen:
        seen.add(v["name"])
        venues.append(v)
venue = {v["name"]: v for v in venues}
print("Venues:", [v["name"] for v in venues])

# --- Create system user ---
uid = "00000000-0000-0000-0000-000000000001"
try:
    requests.post(f"{BASE}/users/", json={"id": uid, "email": "system@drop.app", "username": "Drop"})
except:
    pass

# Monterrey coords (where venues are)
rallies = [
    # LIVE NOW
    dict(title="Rooftop en Pangea", description="Vista al Cerro de la Silla, buena música y cócteles de autor.", creator_id=uid,
         venue_id=venue["Pangea"]["id"], entry_fee=0, max_participants=40,
         starts_at=ts(-1), expires_at=ts(4), lat=25.674, lng=-100.299, category="bar", tags=["#gratis","#rooftop","#vistas"]),
    dict(title="Taco run Barrio Antiguo", description="Ruta de tacos por los mejores puestos. Sale de El Abuelo.", creator_id=uid,
         venue_id=venue["Tacos El Abuelo"]["id"], entry_fee=0, max_participants=15,
         starts_at=ts(-0, 20), expires_at=ts(3), lat=25.668, lng=-100.309, category="comida", tags=["#tacos","#nocturno","#local"]),
    # STARTING SOON
    dict(title="DJ set en Chroma Club", description="Open bar primeras 2 horas. Música electrónica.", creator_id=uid,
         venue_id=venue["Chroma Club"]["id"], entry_fee=150, max_participants=80,
         starts_at=ts(0, 40), expires_at=ts(5), lat=25.656, lng=-100.4035, category="musica", tags=["#electrónica","#openbar","#club"]),
    dict(title="Café + trabajo remoto", description="Sesión de trabajo en grupo. Wifi rápido, buen café.", creator_id=uid,
         venue_id=venue["Crema Café"]["id"], entry_fee=0, max_participants=20,
         starts_at=ts(0, 30), expires_at=ts(4), lat=25.6675, lng=-100.311, category="otro", tags=["#trabajo","#café","#networking"]),
    dict(title="Entrenamiento funcional", description="Clase de 45 min. Todos los niveles bienvenidos.", creator_id=uid,
         venue_id=venue["Smart Fit SP"]["id"], entry_fee=80, max_participants=20,
         starts_at=ts(1), expires_at=ts(3), lat=25.654, lng=-100.401, category="gym", tags=["#gym","#ejercicio","#cardio"]),
    dict(title="Noche de mezcal en El Catrin", description="Cata guiada de 5 mezcales artesanales de Oaxaca.", creator_id=uid,
         venue_id=venue["El Catrin"]["id"], entry_fee=200, max_participants=18,
         starts_at=ts(1, 30), expires_at=ts(4), lat=25.6672, lng=-100.3101, category="bar", tags=["#mezcal","#cata","#artesanal"]),
    dict(title="Beach party en Baja", description="Alberca abierta, música en vivo, sushi y cócteles.", creator_id=uid,
         venue_id=venue["Baja Beach Club"]["id"], entry_fee=300, max_participants=60,
         starts_at=ts(2), expires_at=ts(6), lat=25.657, lng=-100.402, category="otro", tags=["#pool","#música","#fiesta"]),
    dict(title="Arte urbano en vivo", description="Artistas muralizan en tiempo real. Puedes participar.", creator_id=uid,
         venue_id=None, entry_fee=0, max_participants=30,
         starts_at=ts(0, 50), expires_at=ts(5), lat=25.670, lng=-100.305, category="arte", tags=["#gratis","#mural","#arte-urbano"]),
]

ok = 0
for r in rallies:
    resp = requests.post(f"{BASE}/rallies/", json=r)
    if resp.status_code == 200:
        ok += 1
        print(f"  ✓ {r['title']}")
    else:
        print(f"  ✗ {r['title']}: {resp.text[:80]}")

print(f"\nRallies creados: {ok}/{len(rallies)}")
print(f"Verifica: {BASE}/rallies/")

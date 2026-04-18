from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import rallies, venues, participants, users

app = FastAPI(title="Drop API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(rallies.router)
app.include_router(venues.router)
app.include_router(participants.router)
app.include_router(users.router)


@app.get("/")
def health():
    return {"status": "ok", "app": "Drop API"}

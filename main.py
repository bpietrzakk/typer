from fastapi import FastAPI
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

from routers import admin, auth, matches, predictions, ranking

app = FastAPI(title="Typer Ligowy")

app.include_router(auth.router)
app.include_router(matches.router)
app.include_router(predictions.router)
app.include_router(ranking.router)
app.include_router(admin.router)

# serve frontend folder as static files
app.mount("/frontend", StaticFiles(directory="frontend"), name="frontend")


@app.get("/")
def root():
    # redirect root to the frontend page
    return FileResponse("frontend/index.html")


@app.get("/health")
def health():
    return {"status": "ok"}

from fastapi import FastAPI

from routers import admin, matches, predictions, ranking

app = FastAPI(title="Typer Ligowy")

app.include_router(matches.router)
app.include_router(predictions.router)
app.include_router(ranking.router)
app.include_router(admin.router)


@app.get("/health")
def health():
    return {"status": "ok"}

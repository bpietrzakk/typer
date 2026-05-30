from fastapi import FastAPI

app = FastAPI(title="Typer Ligowy")


@app.get("/health")
def health():
    return {"status": "ok"}

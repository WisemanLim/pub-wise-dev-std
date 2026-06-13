"""{{PROJECT_NAME}} — FastAPI entrypoint (정적 템플릿 / static scaffold)."""
from fastapi import FastAPI

from app.core.config import settings

app = FastAPI(title=settings.app_name)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "env": settings.env}

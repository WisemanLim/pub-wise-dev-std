"""{{PROJECT_NAME}} — settings (env-driven)."""
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env.local", extra="ignore")

    app_name: str = "{{PROJECT_NAME}}"
    env: str = "local"
    database_url: str = "sqlite:///./local.db"
    redis_url: str = ""


settings = Settings()

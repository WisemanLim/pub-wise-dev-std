// {{PROJECT_NAME}} — axum entrypoint (정적 템플릿 / static scaffold)
use axum::{routing::get, Json, Router};
use serde_json::json;

#[tokio::main]
async fn main() {
    let app = Router::new().route("/health", get(health));
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000").await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn health() -> Json<serde_json::Value> {
    let env = std::env::var("ENV").unwrap_or_else(|_| "local".into());
    Json(json!({ "status": "ok", "env": env }))
}

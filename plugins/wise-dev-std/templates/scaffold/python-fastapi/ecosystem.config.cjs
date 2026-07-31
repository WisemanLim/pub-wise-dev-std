// {{PROJECT_NAME}} — PM2 process manager (PROC_MGR=pm2 대안, honcho 기본 대신 사용 시)
// 실행: make local-all PROC_MGR=pm2  (= npx pm2 start ecosystem.config.cjs)
// Node/npx 필요. 기본값은 honcho(Procfile.dev) — 이 파일은 pm2 선호 시에만 사용.
module.exports = {
  apps: [
    {
      name: '{{PROJECT_NAME}}-web',
      script: 'uv',
      args: 'run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000',
      interpreter: 'none',
    },
    // 워커 예시(필요 시 주석 해제 — arq/celery/rq 등):
    // { name: '{{PROJECT_NAME}}-worker', script: 'uv', args: 'run python -m app.worker', interpreter: 'none' },
  ],
};

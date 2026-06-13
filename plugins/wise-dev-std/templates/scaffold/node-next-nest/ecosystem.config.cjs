// {{PROJECT_NAME}} — PM2 process manager (local / bare-metal multi-process)
// 호스트 직접 실행 시 web+api 를 한 번에 관리: `make run` (= pnpm exec pm2 start ecosystem.config.cjs)
// 컨테이너(K8s)에서는 사용하지 않음. PM2 는 베어메탈 prod 기동에도 재사용 가능.
module.exports = {
  apps: [
    {
      name: '{{PROJECT_NAME}}-web',
      cwd: 'apps/web',
      script: 'pnpm',
      args: 'dev',
      interpreter: 'none',     // pnpm 은 바이너리 → node 인터프리터 비활성
      env: { PORT: 3000 },
    },
    {
      name: '{{PROJECT_NAME}}-api',
      cwd: 'apps/api',
      script: 'pnpm',
      args: 'dev',
      interpreter: 'none',
      env: { PORT: 4000 },
    },
    // 워커 예시(필요 시 주석 해제):
    // { name: '{{PROJECT_NAME}}-worker', cwd: 'apps/api', script: 'pnpm', args: 'worker', interpreter: 'none' },
  ],
};

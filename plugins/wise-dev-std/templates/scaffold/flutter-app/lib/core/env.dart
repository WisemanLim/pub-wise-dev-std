// {{PROJECT_NAME}} — flavor → API base (build-time via --dart-define)
class Env {
  static const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  static const apiBase =
      String.fromEnvironment('API_BASE', defaultValue: 'http://localhost:8000');
}

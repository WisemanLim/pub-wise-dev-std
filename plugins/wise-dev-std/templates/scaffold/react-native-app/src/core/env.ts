// {{PROJECT_NAME}} — flavor → API base (EAS profile / app.json extra 로 주입)
import Constants from "expo-constants";

const extra = (Constants.expoConfig?.extra ?? {}) as Record<string, string>;

export const Env = {
  flavor: extra.flavor ?? process.env.EXPO_PUBLIC_FLAVOR ?? "development",
  apiBase: extra.apiBase ?? process.env.EXPO_PUBLIC_API_BASE ?? "http://localhost:8000",
};

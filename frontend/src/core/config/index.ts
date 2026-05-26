import { env } from "@/env";

function getBaseOrigin() {
  if (typeof window !== "undefined") {
    return window.location.origin;
  }
  // Fallback for SSR
  return "http://localhost:2026";
}

export function getBackendBaseURL() {
  if (env.NEXT_PUBLIC_BACKEND_BASE_URL) {
    return new URL(env.NEXT_PUBLIC_BACKEND_BASE_URL, getBaseOrigin())
      .toString()
      .replace(/\/+$/, "");
  }
  // When embedded with a basePath (e.g. /expert), return it so API calls
  // are routed through the embedding app's proxy chain.
  if (env.NEXT_PUBLIC_BASE_PATH) {
    return env.NEXT_PUBLIC_BASE_PATH;
  }
  return "";
}

export function getLangGraphBaseURL(isMock?: boolean) {
  console.log(
    "env.NEXT_PUBLIC_LANGGRAPH_BASE_URL",
    env.NEXT_PUBLIC_LANGGRAPH_BASE_URL,
  );
  if (env.NEXT_PUBLIC_LANGGRAPH_BASE_URL) {
    return new URL(
      env.NEXT_PUBLIC_LANGGRAPH_BASE_URL,
      getBaseOrigin(),
    ).toString();
  } else if (isMock) {
    if (typeof window !== "undefined") {
      return `${window.location.origin}/mock/api`;
    }
    return "http://localhost:3000/mock/api";
  } else {
    // LangGraph SDK requires a full URL, construct it from current origin
    const basePath = env.NEXT_PUBLIC_BASE_PATH ?? "";
    if (typeof window !== "undefined") {
      return `${window.location.origin}${basePath}/api/langgraph`;
    }
    // Fallback for SSR
    return `http://localhost:2026${basePath}/api/langgraph`;
  }
}

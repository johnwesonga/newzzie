/// Save application state to sessionStorage
export function saveState(stateJson) {
  try {
    sessionStorage.setItem("appState", stateJson);
    console.log("[Session] State saved to sessionStorage:", stateJson);
  } catch (e) {
    console.error("[Session] Failed to save state:", e.message);
  }
  return undefined;
}

/// Restore application state from sessionStorage
export function restoreState() {
  try {
    const state = sessionStorage.getItem("appState");
    if (state === null) {
      console.log("[Session] No state found in sessionStorage");
      return "";
    }
    console.log("[Session] Retrieved state from sessionStorage:", state);
    return state;
  } catch (e) {
    console.error("[Session] Failed to restore state:", e.message);
    return "";
  }
}

/// Navigate to a path using window.history
export function navigateTo(path) {
  try {
    window.history.pushState({}, "", path);
    console.log("[Session] Navigated to:", path);
  } catch (e) {
    console.error("[Session] Failed to navigate to", path, ":", e.message);
  }
  return undefined;
}

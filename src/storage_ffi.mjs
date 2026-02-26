/// Cache a string value in localStorage
export function cacheString(key, value) {
  try {
    localStorage.setItem(key, value);
  } catch (e) {
    console.warn("Failed to cache to localStorage:", e);
  }
  return undefined;
}

/// Get a string value from localStorage
export function getString(key) {
  try {
    const value = localStorage.getItem(key);
    return value === null ? "" : value;
  } catch (e) {
    console.warn("Failed to retrieve from localStorage:", e);
    return "";
  }
}

/// Clear all localStorage data
export function clearAll() {
  try {
    localStorage.clear();
  } catch (e) {
    console.warn("Failed to clear localStorage:", e);
  }
  return undefined;
}

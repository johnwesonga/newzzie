/// Cache a string value in localStorage
export function cacheString(key, value) {
  try {
    const sizeKb = new Blob([value]).size / 1024;
    localStorage.setItem(key, value);
    console.log(
      `[Storage] Cached "${key}" (${sizeKb.toFixed(2)} KB)`,
    );
  } catch (e) {
    console.error(`[Storage] Failed to cache "${key}":`, e.message);
  }
  return undefined;
}

/// Get a string value from localStorage
export function getString(key) {
  try {
    const value = localStorage.getItem(key);
    if (value === null) {
      console.log(`[Storage] Cache miss for "${key}"`);
      return "";
    }
    const sizeKb = new Blob([value]).size / 1024;
    console.log(
      `[Storage] Cache hit for "${key}" (${sizeKb.toFixed(2)} KB)`,
    );
    return value;
  } catch (e) {
    console.error(`[Storage] Failed to retrieve "${key}":`, e.message);
    return "";
  }
}

/// Clear all localStorage data
export function clearAll() {
  try {
    const itemCount = localStorage.length;
    localStorage.clear();
    console.log(`[Storage] Cleared ${itemCount} items from localStorage`);
  } catch (e) {
    console.error("[Storage] Failed to clear localStorage:", e.message);
  }
  return undefined;
}

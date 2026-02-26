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

/// Get current timestamp in seconds
export function getCurrentTimestamp() {
  return Math.floor(Date.now() / 1000);
}

/// Check if cache entry is still valid (within TTL)
export function isCacheValid(cacheData, ttlSeconds) {
  try {
    // Parse cache format: {"t":timestamp,"d":{...}}
    const entry = JSON.parse(cacheData);
    if (!entry.t || !entry.d) {
      console.log("[Storage] Cache entry missing timestamp or data");
      return false;
    }

    const now = Math.floor(Date.now() / 1000);
    const age = now - entry.t;
    const isValid = age < ttlSeconds;

    if (isValid) {
      console.log(`[Storage] Cache valid (age: ${age}s, TTL: ${ttlSeconds}s)`);
    } else {
      console.log(
        `[Storage] Cache expired (age: ${age}s, TTL: ${ttlSeconds}s)`,
      );
    }

    return isValid;
  } catch (e) {
    console.error("[Storage] Error validating cache:", e.message);
    return false;
  }
}


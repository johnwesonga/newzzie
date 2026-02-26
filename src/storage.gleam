import gleam/int
import gleam/io
import gleam/string

/// Cache TTL in seconds (default: 1 hour = 3600 seconds)
const cache_ttl_seconds: Int = 3600

/// Store articles in localStorage with a cache key and TTL
pub fn cache_articles(key: String, json_str: String) -> Nil {
  io.println("[Storage] Caching with key: " <> key)
  let cache_data = create_cache_entry(json_str)
  cache_string(key, cache_data)
}

/// Retrieve cached articles from localStorage if still valid (within TTL)
pub fn get_cached_articles(key: String) -> Result(String, Nil) {
  io.println("[Storage] Retrieving cache for key: " <> key)
  case get_string(key) {
    "" -> {
      io.println("[Storage] Cache miss for key: " <> key)
      Error(Nil)
    }
    cache_data -> {
      case is_cache_valid(cache_data) {
        True -> {
          case extract_json_from_cache(cache_data) {
            Ok(json_str) -> {
              io.println("[Storage] Cache hit for key: " <> key)
              Ok(json_str)
            }
            Error(_) -> {
              io.println("[Storage] Cache corrupted for key: " <> key)
              Error(Nil)
            }
          }
        }
        False -> {
          io.println(
            "[Storage] Cache expired for key: "
            <> key
            <> " (TTL: "
            <> int.to_string(cache_ttl_seconds)
            <> "s)",
          )
          Error(Nil)
        }
      }
    }
  }
}

/// Get cache key for search results
pub fn search_cache_key(query: String, page: Int) -> String {
  "search_" <> query <> "_page_" <> int.to_string(page)
}

/// Get cache key for headlines by country
pub fn headlines_cache_key(country: String, page: Int) -> String {
  "headlines_" <> country <> "_page_" <> int.to_string(page)
}

/// Clear all cached articles
pub fn clear_cache() -> Nil {
  clear_all_storage()
}

// JavaScript interop functions

@external(javascript, "./storage_ffi.mjs", "cacheString")
fn cache_string(key: String, value: String) -> Nil

@external(javascript, "./storage_ffi.mjs", "getString")
fn get_string(key: String) -> String

@external(javascript, "./storage_ffi.mjs", "clearAll")
fn clear_all_storage() -> Nil

@external(javascript, "./storage_ffi.mjs", "getCurrentTimestamp")
fn get_current_timestamp() -> Int

@external(javascript, "./storage_ffi.mjs", "isCacheValid")
fn is_cache_valid_external(cache_data: String, ttl_seconds: Int) -> Bool

// Helper functions for TTL-based cache

/// Create a cache entry with timestamp and TTL metadata
fn create_cache_entry(json_str: String) -> String {
  let timestamp = get_current_timestamp()
  // Format: timestamp|json_data (pipe-delimited to avoid escaping issues)
  int.to_string(timestamp) <> "|" <> json_str
}

/// Check if cached entry is still valid (not expired)
fn is_cache_valid(cache_data: String) -> Bool {
  is_cache_valid_external(cache_data, cache_ttl_seconds)
}

/// Extract the JSON data from a cache entry
fn extract_json_from_cache(cache_data: String) -> Result(String, Nil) {
  // Format is timestamp|json_data, so split on first pipe
  case string.split_once(cache_data, "|") {
    Ok(#(_timestamp, json_data)) -> Ok(json_data)
    Error(_) -> Error(Nil)
  }
}

import gleam/int
import gleam/io

/// Store articles in localStorage with a cache key
pub fn cache_articles(key: String, json_str: String) -> Nil {
  io.println("[Storage] Caching with key: " <> key)
  cache_string(key, json_str)
}

/// Retrieve cached articles from localStorage
pub fn get_cached_articles(key: String) -> Result(String, Nil) {
  io.println("[Storage] Retrieving cache for key: " <> key)
  case get_string(key) {
    "" -> {
      io.println("[Storage] Cache miss for key: " <> key)
      Error(Nil)
    }
    json_str -> {
      io.println("[Storage] Cache hit for key: " <> key)
      Ok(json_str)
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

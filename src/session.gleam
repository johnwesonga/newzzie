import gleam/int
import gleam/io
import models

/// Save application state to sessionStorage
pub fn save_state(model: models.Model) -> Nil {
  io.println("[Session] Saving state to sessionStorage")
  let state_json = serialize_state(model)
  session_save(state_json)
}

/// Restore application state from sessionStorage
pub fn restore_state() -> Nil {
  io.println("[Session] Attempting to restore state from sessionStorage")
  let state_json = session_restore()
  case state_json {
    "" -> io.println("[Session] No saved state found in sessionStorage")
    _ -> io.println("[Session] Restored state from sessionStorage")
  }
}

/// Navigate to a path using browser history
pub fn navigate_to(path: String) -> Nil {
  io.println("[Session] Navigating to: " <> path)
  navigate_to_internal(path)
}

// JavaScript interop

@external(javascript, "./session_ffi.mjs", "saveState")
fn session_save(state_json: String) -> Nil

@external(javascript, "./session_ffi.mjs", "restoreState")
fn session_restore() -> String

@external(javascript, "./session_ffi.mjs", "navigateTo")
fn navigate_to_internal(path: String) -> Nil

// State serialization

/// Serialize model state to JSON string
fn serialize_state(model: models.Model) -> String {
  // Format: {"q":"bitcoin","c":"us","p":2}
  // q = query, c = country, p = page
  let query = model.current_query
  let country = model.current_country
  let page = int.to_string(model.current_page)

  "{\"q\":\"" <> query <> "\",\"c\":\"" <> country <> "\",\"p\":" <> page <> "}"
}

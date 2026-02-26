import gleam/int
import gleam/uri.{type Uri}

pub type Route {
  Home
  Search(query: String, page: Int)
  Headlines(country: String, page: Int)
  HeadlinesBySources(sources: String, page: Int)
  About
  NotFound(uri: Uri)
}

pub fn parse_route(uri: Uri) -> Route {
  case uri.path_segments(uri.path) {
    [] | [""] -> Home
    ["search", query] -> Search(query, 1)
    ["search", query, "page", page_str] -> {
      case int.parse(page_str) {
        Ok(page) -> Search(query, page)
        Error(_) -> Search(query, 1)
      }
    }
    ["headlines", country] -> Headlines(country, 1)
    ["headlines", country, "page", page_str] -> {
      case int.parse(page_str) {
        Ok(page) -> Headlines(country, page)
        Error(_) -> Headlines(country, 1)
      }
    }
    ["top-headlines", "sources", sources] -> HeadlinesBySources(sources, 1)
    ["top-headlines", "sources", sources, "page", page_str] -> {
      case int.parse(page_str) {
        Ok(page) -> HeadlinesBySources(sources, page)
        Error(_) -> HeadlinesBySources(sources, 1)
      }
    }
    ["about"] -> About
    _ -> NotFound(uri)
  }
}

/// Build URL for a route
pub fn route_to_path(route: Route) -> String {
  case route {
    Home -> "/"
    Search(query, page) -> {
      case page {
        1 -> "/search/" <> query
        _ -> "/search/" <> query <> "/page/" <> int.to_string(page)
      }
    }
    Headlines(country, page) -> {
      case page {
        1 -> "/headlines/" <> country
        _ -> "/headlines/" <> country <> "/page/" <> int.to_string(page)
      }
    }
    HeadlinesBySources(sources, page) -> {
      case page {
        1 -> "/top-headlines/sources/" <> sources
        _ ->
          "/top-headlines/sources/"
          <> sources
          <> "/page/"
          <> int.to_string(page)
      }
    }
    About -> "/about"
    NotFound(_) -> "/"
  }
}

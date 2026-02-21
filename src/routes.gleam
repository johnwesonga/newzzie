import gleam/uri.{type Uri}

pub type Route {
  Home
  Search(query: String)
  Headlines(country: String)
  HeadlinesBySources(sources: String)
  NotFound(uri: Uri)
}

pub fn parse_route(uri: Uri) -> Route {
  case uri.path_segments(uri.path) {
    [] | [""] -> Home
    ["search", query] -> Search(query)
    ["headlines", country] -> Headlines(country)
    ["top-headlines", "sources", sources] -> HeadlinesBySources(sources)
    _ -> NotFound(uri)
  }
}

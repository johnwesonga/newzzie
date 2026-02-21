import gleam/uri
import gleeunit
import gleeunit/should
import routes

pub fn main() -> Nil {
  gleeunit.main()
}

// Test home route parsing
pub fn parse_route_home_test() {
  let uri = uri.parse("/") |> should.be_ok
  let route = routes.parse_route(uri)
  route |> should.equal(routes.Home)
}

// Test home route with empty path
pub fn parse_route_home_empty_test() {
  let uri = uri.parse("") |> should.be_ok
  let route = routes.parse_route(uri)
  route |> should.equal(routes.Home)
}

// Test search route parsing
pub fn parse_route_search_test() {
  let uri = uri.parse("/search/bitcoin") |> should.be_ok
  let route = routes.parse_route(uri)
  route |> should.equal(routes.Search("bitcoin"))
}

// Test search route with multiple words (encoded)
pub fn parse_route_search_multi_word_test() {
  let uri = uri.parse("/search/cryptocurrency%20news") |> should.be_ok
  let route = routes.parse_route(uri)
  route |> should.equal(routes.Search("cryptocurrency%20news"))
}

// Test headlines route parsing
pub fn parse_route_headlines_test() {
  let uri = uri.parse("/headlines/us") |> should.be_ok
  let route = routes.parse_route(uri)
  route |> should.equal(routes.Headlines("us"))
}

// Test headlines with different countries
pub fn parse_route_headlines_gb_test() {
  let uri = uri.parse("/headlines/gb") |> should.be_ok
  let route = routes.parse_route(uri)
  route |> should.equal(routes.Headlines("gb"))
}

pub fn parse_route_headlines_de_test() {
  let uri = uri.parse("/headlines/de") |> should.be_ok
  let route = routes.parse_route(uri)
  route |> should.equal(routes.Headlines("de"))
}

// Test headlines by sources route parsing
pub fn parse_route_sources_single_test() {
  let uri = uri.parse("/top-headlines/sources/bbc-news") |> should.be_ok
  let route = routes.parse_route(uri)
  route |> should.equal(routes.HeadlinesBySources("bbc-news"))
}

// Test headlines by sources with multiple sources
pub fn parse_route_sources_multiple_test() {
  let uri = uri.parse("/top-headlines/sources/bbc-news,cnn,fox-news") |> should.be_ok
  let route = routes.parse_route(uri)
  route |> should.equal(routes.HeadlinesBySources("bbc-news,cnn,fox-news"))
}

// Test not found route for invalid path
pub fn parse_route_not_found_test() {
  let uri = uri.parse("/invalid/path") |> should.be_ok
  let route = routes.parse_route(uri)
  case route {
    routes.NotFound(_) -> True
    _ -> False
  }
  |> should.be_true
}

// Test not found route for nested invalid path
pub fn parse_route_not_found_nested_test() {
  let uri = uri.parse("/foo/bar/baz") |> should.be_ok
  let route = routes.parse_route(uri)
  case route {
    routes.NotFound(_) -> True
    _ -> False
  }
  |> should.be_true
}

// Test not found route preserves URI
pub fn parse_route_not_found_uri_preserved_test() {
  let uri = uri.parse("/nonexistent") |> should.be_ok
  let route = routes.parse_route(uri)
  case route {
    routes.NotFound(returned_uri) -> returned_uri == uri
    _ -> False
  }
  |> should.be_true
}

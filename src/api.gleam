import gleam/dynamic/decode
import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import lustre/effect
import models
import rsvp

const base_url: String = "https://newsapi.org/v2"

const api_key: String = "a688e6494c444902b1fc9cb93c61d697"

pub opaque type Error {
  RequestFailed(rsvp.Error)
}

/// Constructs a URL with query parameters.
///
/// Converts a base URL and a list of key-value parameter pairs into a complete
/// URL with query string. Parameters are joined with "&" separators.
///
/// # Parameters
///
/// - `base` - The base URL (e.g., "https://newsapi.org/v2/everything")
/// - `params` - A list of (key, value) tuples representing query parameters
///
/// # Returns
///
/// A complete URL with query string appended (e.g., "https://newsapi.org/v2/everything?q=bitcoin&apiKey=abc123")
///
/// # Example
///
/// ```gleam
/// build_url("https://newsapi.org/v2/everything", [
///   #("q", "bitcoin"),
///   #("apiKey", "abc123"),
/// ])
/// // Returns: "https://newsapi.org/v2/everything?q=bitcoin&apiKey=abc123"
/// ```
fn build_url(base: String, params: List(#(String, String))) -> String {
  let query_parts =
    list.map(params, fn(param) {
      let #(key, value) = param
      key <> "=" <> value
    })

  base <> "?" <> string.join(query_parts, "&")
}

/// Fetches all articles matching the provided query from the news API.
///
/// # Parameters
///
/// - `query` - The search query string to find relevant articles
/// - `page` - The page number for pagination (1-indexed)
/// - `on_response` - Callback function to handle the API response containing a list of articles, count, and raw JSON
///
/// # Returns
///
/// An Effect that will perform the HTTP GET request and invoke the callback with the result.
/// Errors are wrapped in the RequestFailed variant.
pub fn everything(
  query: String,
  page: Int,
  on_response: fn(Result(#(List(models.Article), String), Error)) -> msg,
) -> effect.Effect(msg) {
  let url =
    build_url(base_url <> "/everything", [
      #("q", query),
      #("page", int.to_string(page)),
      #("pageSize", "20"),
      #("apiKey", api_key),
    ])

  rsvp.get(
    url,
    rsvp.expect_json(articles_with_raw_decoder(), fn(result) {
      on_response(result.map_error(result, fn(err) { RequestFailed(err) }))
    }),
  )
}

/// Fetches the top headlines for a specified country from the NewsAPI.
///
/// # Arguments
///
/// * `country` - The country code (e.g., "us", "gb") for which to fetch headlines
/// * `page` - The page number for pagination (1-indexed)
/// * `on_response` - A callback function that handles the response, receiving either
///   a list of articles and raw JSON or a request error
///
/// # Returns
///
/// An effect that, when executed, will make a GET request to the top-headlines
/// endpoint and invoke the callback with the result.
///
/// # Errors
///
/// If the request fails, the error is wrapped in a `RequestFailed` variant
/// before being passed to the callback.
pub fn top_headlines(
  country: String,
  page: Int,
  on_response: fn(Result(#(List(models.Article), String), Error)) -> msg,
) -> effect.Effect(msg) {
  let url =
    build_url(base_url <> "/top-headlines", [
      #("country", country),
      #("page", int.to_string(page)),
      #("pageSize", "20"),
      #("apiKey", api_key),
    ])

  rsvp.get(
    url,
    rsvp.expect_json(articles_with_raw_decoder(), fn(result) {
      on_response(result.map_error(result, fn(err) { RequestFailed(err) }))
    }),
  )
}

/// Fetches top news headlines from specified news sources.
///
/// # Arguments
///
/// - `sources` - A list of news source identifiers to fetch headlines from
/// - `page` - The page number for pagination (1-indexed)
/// - `on_response` - A callback function that handles the response, receiving either
///   a list of articles and raw JSON or an error
///
/// # Returns
///
/// An effect that, when executed, will make an HTTP GET request to fetch headlines
/// from the specified sources and pass the result to the provided callback.
pub fn top_headlines_by_source(
  sources: List(String),
  page: Int,
  on_response: fn(Result(#(List(models.Article), String), Error)) -> msg,
) -> effect.Effect(msg) {
  let sources_str = string.join(sources, ",")
  let url =
    build_url(base_url <> "/top-headlines", [
      #("sources", sources_str),
      #("page", int.to_string(page)),
      #("pageSize", "20"),
      #("apiKey", api_key),
    ])

  rsvp.get(
    url,
    rsvp.expect_json(articles_with_raw_decoder(), fn(result) {
      on_response(result.map_error(result, fn(err) { RequestFailed(err) }))
    }),
  )
}

// Decoders
/// Decodes a JSON response containing a list of articles along with the raw JSON string.
///
/// This decoder captures both the parsed articles and the original JSON string
/// for caching purposes.
fn articles_with_raw_decoder() -> decode.Decoder(
  #(List(models.Article), String),
) {
  use articles <- decode.field("articles", decode.list(article_decoder()))
  // Store raw JSON by serializing articles back
  let json_str = articles_to_json_string(articles)
  decode.success(#(articles, json_str))
}

/// Decodes a JSON object into an Article model.
///
/// This decoder handles the following fields:
/// - `source`: Required source object decoded via source_decoder()
/// - `author`: Optional string, defaults to empty string if not present
/// - `title`: Required string
/// - `description`: Optional string, defaults to empty string if not present
/// - `url`: Required string
/// - `urlToImage`: Optional string, defaults to empty string if not present
/// - `publishedAt`: Required string
/// - `content`: Optional string, defaults to empty string if not present
///
/// Returns a Decoder that produces an Article record with all optional fields
/// unwrapped and defaulted to empty strings when absent.
fn article_decoder() -> decode.Decoder(models.Article) {
  use source <- decode.field("source", source_decoder())
  use author <- decode.field("author", decode.optional(decode.string))
  use title <- decode.field("title", decode.string)
  use description <- decode.field("description", decode.optional(decode.string))
  use url <- decode.field("url", decode.string)
  use url_to_image <- decode.field("urlToImage", decode.optional(decode.string))
  use published_at <- decode.field("publishedAt", decode.string)
  use content <- decode.field("content", decode.optional(decode.string))

  decode.success(models.Article(
    source: source,
    author: option.unwrap(author, ""),
    title: title,
    description: option.unwrap(description, ""),
    url: url,
    url_to_image: option.unwrap(url_to_image, ""),
    published_at: published_at,
    content: option.unwrap(content, ""),
  ))
}

/// Decodes a Source object from JSON data.
///
/// Expects a JSON object with the following fields:
/// - `id`: optional string field, defaults to empty string if not provided
/// - `name`: required string field
///
/// Returns a decoder that produces a `models.Source` record with the decoded values.
fn source_decoder() -> decode.Decoder(models.Source) {
  use id <- decode.field("id", decode.optional(decode.string))
  use name <- decode.field("name", decode.string)

  decode.success(models.Source(id: option.unwrap(id, ""), name: name))
}

/// Serialize articles back to JSON string for caching
fn articles_to_json_string(articles: List(models.Article)) -> String {
  let json_articles =
    list.map(articles, fn(article) {
      "{\"source\":"
      <> "{\"id\":\""
      <> article.source.id
      <> "\",\"name\":\""
      <> article.source.name
      <> "\"},"
      <> "\"author\":\""
      <> article.author
      <> "\","
      <> "\"title\":\""
      <> article.title
      <> "\","
      <> "\"description\":\""
      <> article.description
      <> "\","
      <> "\"url\":\""
      <> article.url
      <> "\","
      <> "\"urlToImage\":\""
      <> article.url_to_image
      <> "\","
      <> "\"publishedAt\":\""
      <> article.published_at
      <> "\","
      <> "\"content\":\""
      <> article.content
      <> "\"}"
    })

  "[" <> string.join(json_articles, ",") <> "]"
}

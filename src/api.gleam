import gleam/dynamic/decode
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import lustre/effect
import models
import rsvp

const base_url = "https://newsapi.org/v2"

/// Represents an error that occurs during API operations.
///
/// ## Variants
///
/// - `RequestFailed(rsvp.Error)` - Indicates that an HTTP request failed with the given RSVP error.
pub opaque type Error {
  RequestFailed(rsvp.Error)
}

/// Constructs a URL by appending query parameters to a base URL.
///
/// Takes a base URL string and a list of key-value parameter pairs,
/// then combines them into a single URL string with properly formatted
/// query parameters.
///
/// # Arguments
///
/// * `base` - The base URL string
/// * `params` - A list of tuples containing parameter key-value pairs
///
/// # Returns
///
/// A complete URL string with query parameters appended in the format:
/// `base?key1=value1&key2=value2`
///
/// # Examples
///
/// ```gleam
/// build_url("https://api.example.com/users", [#("id", "123"), #("active", "true")])
/// // "https://api.example.com/users?id=123&active=true"
/// ```
  api_key: String,
  on_response: fn(Result(List(models.Article), Error)) -> msg,
) -> effect.Effect(msg) {
  let url =
    build_url(base_url <> "/top-headlines", [
      #("country", country),
      #("apiKey", api_key),
    ])

  rsvp.get(
    url,
    rsvp.expect_json(articles_decoder(), fn(result) {
      on_response(result.map_error(result, fn(err) { RequestFailed(err) }))
    }),
  )
}

/// Fetches top news headlines from specified news sources.
///
/// # Arguments
///
/// - `sources` - A list of news source identifiers to fetch headlines from
/// - `api_key` - The API key for authenticating with the news service
/// - `on_response` - A callback function that handles the response, receiving either
///   a list of articles or an error
///
/// # Returns
///
/// An effect that, when executed, will make an HTTP GET request to fetch headlines
/// from the specified sources and pass the result to the provided callback.
pub fn top_headlines_by_source(
  sources: List(String),
  api_key: String,
  on_response: fn(Result(List(models.Article), Error)) -> msg,
) -> effect.Effect(msg) {
  let sources_str = string.join(sources, ",")
  let url =
    build_url(base_url <> "/top-headlines", [
      #("sources", sources_str),
      #("apiKey", api_key),
    ])

  rsvp.get(
    url,
    rsvp.expect_json(articles_decoder(), fn(result) {
      on_response(result.map_error(result, fn(err) { RequestFailed(err) }))
    }),
  )
}

// Decoders
/// Decodes a JSON response containing a list of articles.
///
/// Expects a JSON object with an "articles" field containing an array of article objects.
/// Each article in the array is decoded using the `article_decoder()`.
///
/// # Returns
///
/// A `Decoder` that produces a `List(Article)` when successfully decoded.
fn articles_decoder() -> decode.Decoder(List(models.Article)) {
  use articles <- decode.field("articles", decode.list(article_decoder()))
  decode.success(articles)
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

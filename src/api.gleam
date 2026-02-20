import gleam/dynamic/decode
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import lustre/effect
import models
import rsvp

pub opaque type Error {
  RequestFailed(rsvp.Error)
}

fn build_url(base: String, params: List(#(String, String))) -> String {
  let query_parts =
    list.map(params, fn(param) {
      let #(key, value) = param
      key <> "=" <> value
    })

  base <> "?" <> string.join(query_parts, "&")
}

pub fn everything(
  query: String,
  api_key: String,
  on_response: fn(Result(List(models.Article), Error)) -> msg,
) -> effect.Effect(msg) {
  let url =
    build_url("https://newsapi.org/v2/everything", [
      #("q", query),
      #("apiKey", api_key),
    ])

  rsvp.get(
    url,
    rsvp.expect_json(articles_decoder(), fn(result) {
      on_response(result.map_error(result, fn(err) { RequestFailed(err) }))
    }),
  )
}

pub fn top_headlines(
  country: String,
  api_key: String,
  on_response: fn(Result(List(models.Article), Error)) -> msg,
) -> effect.Effect(msg) {
  let url =
    build_url("https://newsapi.org/v2/top-headlines", [
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

pub fn top_headlines_by_source(
  sources: List(String),
  api_key: String,
  on_response: fn(Result(List(models.Article), Error)) -> msg,
) -> effect.Effect(msg) {
  let sources_str = string.join(sources, ",")
  let url =
    build_url("https://newsapi.org/v2/top-headlines", [
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
fn articles_decoder() -> decode.Decoder(List(models.Article)) {
  use articles <- decode.field("articles", decode.list(article_decoder()))
  decode.success(articles)
}

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

fn source_decoder() -> decode.Decoder(models.Source) {
  use id <- decode.field("id", decode.optional(decode.string))
  use name <- decode.field("name", decode.string)

  decode.success(models.Source(id: option.unwrap(id, ""), name: name))
}

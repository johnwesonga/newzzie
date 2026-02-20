import gleeunit
import gleeunit/should
import gleam/list
import gleam/string
import models

pub fn main() -> Nil {
  gleeunit.main()
}

// Test article creation
pub fn article_creation_test() {
  let source = models.Source(id: "test", name: "Test News")
  let article =
    models.Article(
      source: source,
      author: "Test Author",
      title: "Test Title",
      description: "Test Description",
      url: "https://test.com",
      url_to_image: "https://test.com/img.jpg",
      published_at: "2026-02-20T10:00:00Z",
      content: "Test content",
    )

  should.equal(article.title, "Test Title")
  should.equal(article.author, "Test Author")
  should.equal(article.source.name, "Test News")
}

// Test source creation
pub fn source_creation_test() {
  let source = models.Source(id: "bbc-news", name: "BBC News")

  should.equal(source.id, "bbc-news")
  should.equal(source.name, "BBC News")
}

// Test source with empty id
pub fn source_empty_id_test() {
  let source = models.Source(id: "", name: "CNN")

  should.equal(source.id, "")
  should.equal(source.name, "CNN")
}

// Test URL parameter building
pub fn build_url_params_test() {
  let params = [#("q", "bitcoin"), #("apiKey", "test-key")]

  let query_parts =
    list.map(params, fn(param) {
      let #(key, value) = param
      key <> "=" <> value
    })

  let query_string = string.join(query_parts, "&")

  should.equal(query_string, "q=bitcoin&apiKey=test-key")
}

// Test URL construction
pub fn build_full_url_test() {
  let base = "https://newsapi.org/v2/everything"
  let params = [#("q", "bitcoin"), #("apiKey", "test-key")]

  let query_parts =
    list.map(params, fn(param) {
      let #(key, value) = param
      key <> "=" <> value
    })

  let query_string = string.join(query_parts, "&")
  let url = base <> "?" <> query_string

  should.equal(url, "https://newsapi.org/v2/everything?q=bitcoin&apiKey=test-key")
}

// Test article with all required fields
pub fn article_required_fields_test() {
  let source = models.Source(id: "bbc", name: "BBC News")
  let article =
    models.Article(
      source: source,
      author: "",
      title: "News",
      description: "",
      url: "https://bbc.com",
      url_to_image: "",
      published_at: "2026-02-20T10:00:00Z",
      content: "",
    )

  should.equal(article.title, "News")
  should.equal(article.url, "https://bbc.com")
  should.equal(article.published_at, "2026-02-20T10:00:00Z")
}

// Test multiple sources
pub fn multiple_sources_test() {
  let source1 = models.Source(id: "bbc", name: "BBC News")
  let source2 = models.Source(id: "cnn", name: "CNN")
  let source3 = models.Source(id: "", name: "Tech News")

  should.equal(source1.name, "BBC News")
  should.equal(source2.name, "CNN")
  should.equal(source3.id, "")
}

// Test application initialization
pub fn app_init_test() {
  let model = models.init()

  should.equal(model.loading, False)
  should.equal(model.error, "")
  should.equal(model.current_query, "")
  should.equal(model.current_country, "us")
  should.equal(list.length(model.articles), 0)
}

// Test model with loaded articles
pub fn model_with_articles_test() {
  let source = models.Source(id: "bbc", name: "BBC News")
  let article1 =
    models.Article(
      source: source,
      author: "Author 1",
      title: "Article 1",
      description: "Description 1",
      url: "https://example.com/1",
      url_to_image: "https://example.com/1.jpg",
      published_at: "2026-02-20T10:00:00Z",
      content: "Content 1",
    )
  let article2 =
    models.Article(
      source: source,
      author: "Author 2",
      title: "Article 2",
      description: "Description 2",
      url: "https://example.com/2",
      url_to_image: "https://example.com/2.jpg",
      published_at: "2026-02-20T11:00:00Z",
      content: "Content 2",
    )

  let model =
    models.Model(
      articles: [article1, article2],
      loading: False,
      error: "",
      current_query: "bitcoin",
      current_country: "us",
    )

  should.equal(list.length(model.articles), 2)
  should.equal(model.current_query, "bitcoin")
}

// Test model loading state
pub fn model_loading_state_test() {
  let model =
    models.Model(
      articles: [],
      loading: True,
      error: "",
      current_query: "news",
      current_country: "gb",
    )

  should.equal(model.loading, True)
  should.equal(model.current_country, "gb")
}

// Test model with error
pub fn model_with_error_test() {
  let model =
    models.Model(
      articles: [],
      loading: False,
      error: "Network error occurred",
      current_query: "",
      current_country: "us",
    )

  should.equal(model.error, "Network error occurred")
}

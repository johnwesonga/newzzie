import lustre/element.{type Element}
import lustre/element/html
import lustre/attribute
import gleam/list
import models

// Render the main application view
pub fn view(model: models.Model) -> Element(models.Msg) {
  html.div(
    [attribute.class("container")],
    [
      view_header(),
      view_search_form(),
      view_content(model),
    ],
  )
}

// Render header section
fn view_header() -> Element(models.Msg) {
  html.header([attribute.class("header")], [
    html.h1([], [element.text("Newzzie")]),
    html.p([attribute.class("subtitle")], [
      element.text("Browse and search news from around the world"),
    ]),
  ])
}

// Render search form
fn view_search_form() -> Element(models.Msg) {
  html.section([attribute.class("search-section")], [
    html.h2([], [element.text("Search News")]),
    html.div([attribute.class("search-form")], [
      html.input([
        attribute.placeholder("Enter keyword to search..."),
        attribute.class("search-input"),
      ]),
      html.button([attribute.class("search-button")], [
        element.text("Search"),
      ]),
    ]),
    html.div([attribute.class("filters")], [
      html.label([], [element.text("Filter by country: US, UK, CA, etc.")]),
    ]),
  ])
}

// Render main content based on state
fn view_content(model: models.Model) -> Element(models.Msg) {
  case model.loading, list.is_empty(model.articles), model.error {
    True, _, _ -> view_loading()
    _, _, err if err != "" -> view_error(err)
    _, True, _ -> view_empty_state()
    _, False, _ -> view_articles(model.articles)
  }
}

// Render loading state
fn view_loading() -> Element(models.Msg) {
  html.div([attribute.class("loading-container")], [
    html.div([attribute.class("spinner")], []),
    html.p([], [element.text("Loading articles...")]),
  ])
}

// Render error state
fn view_error(error: String) -> Element(models.Msg) {
  html.div([attribute.class("error-container")], [
    html.div([attribute.class("error-message")], [
      element.text("Error: " <> error),
    ]),
  ])
}

// Render empty state
fn view_empty_state() -> Element(models.Msg) {
  html.div([attribute.class("empty-state")], [
    html.p([], [element.text("No articles found. Try searching for something!")]),
  ])
}

// Render list of articles
fn view_articles(articles: List(models.Article)) -> Element(models.Msg) {
  html.section([attribute.class("articles-section")], [
    html.h2([], [element.text("Articles")]),
    html.ul([attribute.class("articles-list")], list.map(articles, view_article)),
  ])
}

// Render single article
fn view_article(article: models.Article) -> Element(models.Msg) {
  html.li([attribute.class("article-item")], [
    html.article([attribute.class("article-card")], [
      view_article_image(article.url_to_image),
      html.div([attribute.class("article-content")], [
        view_article_source(article.source),
        html.h3([attribute.class("article-title")], [
          html.a(
            [attribute.href(article.url), attribute.target("_blank")],
            [element.text(article.title)],
          ),
        ]),
        view_article_meta(article),
        view_article_description(article.description),
      ]),
    ]),
  ])
}

// Render article image
fn view_article_image(image_url: String) -> Element(models.Msg) {
  case image_url {
    "" ->
      html.div([attribute.class("article-placeholder")], [
        element.text("No image"),
      ])
    url ->
      html.img([
        attribute.src(url),
        attribute.alt("Article image"),
        attribute.class("article-image"),
      ])
  }
}

// Render article source
fn view_article_source(source: models.Source) -> Element(models.Msg) {
  html.div([attribute.class("article-source")], [
    html.span([attribute.class("source-name")], [element.text(source.name)]),
  ])
}

// Render article metadata (author, date)
fn view_article_meta(article: models.Article) -> Element(models.Msg) {
  html.div([attribute.class("article-meta")], [
    case article.author {
      "" -> element.none()
      author ->
        html.span([attribute.class("article-author")], [
          element.text("By " <> author),
        ])
    },
    html.span([attribute.class("article-date")], [
      element.text(article.published_at),
    ]),
  ])
}

// Render article description
fn view_article_description(description: String) -> Element(models.Msg) {
  case description {
    "" -> element.none()
    desc ->
      html.p([attribute.class("article-description")], [
        element.text(desc),
      ])
  }
}

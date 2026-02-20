import lustre/element.{type Element}
import lustre/element/html
import lustre/attribute
import gleam/list
import models

// Render the main application view
pub fn view(model: models.Model) -> Element(models.Msg) {
  html.div(
    [attribute.class("flex flex-col min-h-screen bg-white")],
    [
      view_header(),
      view_search_form(),
      html.div(
        [attribute.class("flex-1 container mx-auto px-4 py-8 max-w-7xl")],
        [view_content(model)],
      ),
      view_footer(),
    ],
  )
}

// Render header section
fn view_header() -> Element(models.Msg) {
  html.header(
    [attribute.class("bg-gradient-to-r from-blue-600 to-blue-800 text-white shadow-lg")],
    [
      html.div([attribute.class("container mx-auto px-4 py-8 max-w-7xl")], [
        html.h1([attribute.class("text-4xl font-bold mb-2")], [
          element.text("Newzzie"),
        ]),
        html.p([attribute.class("text-blue-100 text-lg")], [
          element.text("Browse and search news from around the world"),
        ]),
      ]),
    ],
  )
}

// Render search form
fn view_search_form() -> Element(models.Msg) {
  html.section([attribute.class("bg-gray-100 border-b border-gray-200 py-6")], [
    html.div([attribute.class("container mx-auto px-4 max-w-7xl")], [
      html.h2([attribute.class("text-2xl font-bold text-gray-900 mb-4")], [
        element.text("Search News"),
      ]),
      html.div([attribute.class("flex gap-4 mb-4")], [
        html.input([
          attribute.placeholder("Enter keyword to search..."),
          attribute.class(
            "flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500",
          ),
        ]),
        html.button(
          [attribute.class(
            "px-6 py-2 bg-blue-600 text-white rounded-lg font-semibold hover:bg-blue-700 transition-colors",
          )],
          [element.text("Search")],
        ),
      ]),
      html.div([attribute.class("flex flex-wrap gap-4")], [
        html.label([attribute.class("flex items-center gap-2")], [
          element.text("Filter by country:"),
          html.span(
            [attribute.class("text-gray-600 text-sm")],
            [element.text("US, UK, CA, DE, FR")],
          ),
        ]),
      ]),
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
  html.div(
    [attribute.class("flex flex-col items-center justify-center py-16")],
    [
      html.div([attribute.class("spinner mb-4")], []),
      html.p([attribute.class("text-gray-600 text-lg")], [
        element.text("Loading articles..."),
      ]),
    ],
  )
}

// Render error state
fn view_error(error: String) -> Element(models.Msg) {
  html.div(
    [attribute.class(
      "bg-red-50 border border-red-200 rounded-lg p-6 my-8 max-w-2xl",
    )],
    [
      html.h3([attribute.class("text-red-900 font-bold mb-2")], [
        element.text("Error occurred"),
      ]),
      html.p([attribute.class("text-red-800")], [
        element.text("Error: " <> error),
      ]),
    ],
  )
}

// Render empty state
fn view_empty_state() -> Element(models.Msg) {
  html.div(
    [attribute.class(
      "text-center py-16 bg-gradient-to-br from-gray-50 to-gray-100 rounded-lg",
    )],
    [
      html.p([attribute.class("text-gray-600 text-lg mb-4")], [
        element.text("No articles found."),
      ]),
      html.p([attribute.class("text-gray-500")], [
        element.text("Try searching for something or check back later!"),
      ]),
    ],
  )
}

// Render list of articles
fn view_articles(articles: List(models.Article)) -> Element(models.Msg) {
  html.section([], [
    html.h2(
      [attribute.class("text-3xl font-bold text-gray-900 mb-8")],
      [element.text("Latest Articles")],
    ),
    html.div(
      [attribute.class("grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6")],
      list.map(articles, view_article),
    ),
  ])
}

// Render single article
fn view_article(article: models.Article) -> Element(models.Msg) {
  html.article(
    [attribute.class(
      "article-card bg-white rounded-lg overflow-hidden shadow border border-gray-200",
    )],
    [
      view_article_image(article.url_to_image),
      html.div([attribute.class("p-5 flex flex-col h-full")], [
        view_article_source(article.source),
        html.h3([attribute.class("text-lg font-bold text-gray-900 my-3")], [
          html.a(
            [
              attribute.href(article.url),
              attribute.target("_blank"),
              attribute.class("hover:text-blue-600 transition-colors"),
            ],
            [element.text(article.title)],
          ),
        ]),
        view_article_description(article.description),
        view_article_meta(article),
      ]),
    ],
  )
}

// Render article image
fn view_article_image(image_url: String) -> Element(models.Msg) {
  case image_url {
    "" ->
      html.div(
        [attribute.class("w-full h-48 bg-gradient-to-br from-gray-200 to-gray-300 flex items-center justify-center")],
        [
          html.span([attribute.class("text-gray-500 font-medium")], [
            element.text("No image available"),
          ]),
        ],
      )
    url ->
      html.img([
        attribute.src(url),
        attribute.alt("Article image"),
        attribute.class("w-full h-48 object-cover"),
      ])
  }
}

// Render article source
fn view_article_source(source: models.Source) -> Element(models.Msg) {
  html.div([], [
    html.span(
      [attribute.class("inline-block bg-blue-100 text-blue-800 text-xs font-semibold px-3 py-1 rounded-full")],
      [element.text(source.name)],
    ),
  ])
}

// Render article metadata (author, date)
fn view_article_meta(article: models.Article) -> Element(models.Msg) {
  html.div([attribute.class("mt-auto pt-4 border-t border-gray-200 text-sm text-gray-600")], [
    case article.author {
      "" -> element.none()
      author ->
        html.div([attribute.class("mb-2")], [
          element.text("By " <> author),
        ])
    },
    html.div([attribute.class("text-gray-500 text-xs")], [
      element.text(article.published_at),
    ]),
  ])
}

// Render article description
fn view_article_description(description: String) -> Element(models.Msg) {
  case description {
    "" -> element.none()
    desc ->
      html.p([attribute.class("text-gray-700 text-sm line-clamp-2 mb-3")], [
        element.text(desc),
      ])
  }
}

// Render footer
fn view_footer() -> Element(models.Msg) {
  html.footer([attribute.class("bg-gray-800 text-gray-300 py-8 mt-12")], [
    html.div([attribute.class("container mx-auto px-4 max-w-7xl text-center")], [
      html.p([attribute.class("mb-2")], [
        element.text("Newzzie - Your daily news aggregator"),
      ]),
      html.p([attribute.class("text-gray-400 text-sm")], [
        element.text("Built with Gleam and Lustre | Powered by NewsApi.org"),
      ]),
    ]),
  ])
}

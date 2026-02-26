import gleam/int
import gleam/list
import gleam/string
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import models
import routes

// Render the main application view
pub fn view(model: models.Model) -> Element(models.Msg) {
  html.div([attribute.class("flex flex-col min-h-screen bg-white")], [
    view_header(),
    case model.route {
      routes.Home -> view_search_form(model)
      routes.HeadlinesBySources(_) -> view_search_form(model)
      _ -> element.none()
    },
    html.div([attribute.class("flex-1 container mx-auto px-4 py-8 max-w-7xl")], [
      view_route_content(model),
    ]),
    view_footer(),
  ])
}

// Render content based on current route
fn view_route_content(model: models.Model) -> Element(models.Msg) {
  case model.route {
    routes.Home -> view_content(model)
    routes.Search(query) -> view_search_results(model, query)
    routes.Headlines(country) -> view_headlines_results(model, country)
    routes.HeadlinesBySources(sources) -> view_sources_results(model, sources)
    routes.About -> view_not_found()
    // Placeholder for about page
    routes.NotFound(_) -> view_not_found()
  }
}

// Render header section
fn view_header() -> Element(models.Msg) {
  html.header(
    [
      attribute.class(
        "bg-gradient-to-r from-blue-600 to-blue-800 text-white shadow-lg",
      ),
    ],
    [
      html.div([attribute.class("container mx-auto px-4 max-w-7xl")], [
        html.div([attribute.class("py-8")], [
          html.h1([attribute.class("text-4xl font-bold mb-2")], [
            element.text("Newzzie"),
          ]),
          html.p([attribute.class("text-blue-100 text-lg mb-6")], [
            element.text("Browse and search news from around the world"),
          ]),
        ]),
        view_nav(),
      ]),
    ],
  )
}

// Render navigation
fn view_nav() -> Element(models.Msg) {
  html.nav([attribute.class("flex gap-6 border-t border-blue-400 pt-4 pb-4")], [
    html.a(
      [
        attribute.href("/"),
        attribute.class(
          "text-blue-100 hover:text-white transition-colors font-medium",
        ),
      ],
      [element.text("Home")],
    ),
    html.a(
      [
        attribute.href("/headlines/us"),
        attribute.class(
          "text-blue-100 hover:text-white transition-colors font-medium",
        ),
      ],
      [element.text("Top Headlines")],
    ),
    html.a(
      [
        attribute.href("/top-headlines/sources/bbc-news,cnn,fox-news"),
        attribute.class(
          "text-blue-100 hover:text-white transition-colors font-medium",
        ),
      ],
      [element.text("Top Sources")],
    ),
  ])
}

// Render search form
fn view_search_form(model: models.Model) -> Element(models.Msg) {
  html.section([attribute.class("bg-gray-100 border-b border-gray-200 py-6")], [
    html.div([attribute.class("container mx-auto px-4 max-w-7xl")], [
      html.h2([attribute.class("text-2xl font-bold text-gray-900 mb-4")], [
        element.text("Search News"),
      ]),
      html.div([attribute.class("flex gap-4 mb-4")], [
        html.input([
          attribute.placeholder("Enter keyword to search..."),
          attribute.value(model.current_query),
          attribute.class(
            "flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500",
          ),
          event.on_input(models.SearchQueryChanged),
        ]),
        html.button(
          [
            attribute.class(
              "px-6 py-2 rounded-lg font-semibold transition-colors "
              <> case is_valid_query(model.current_query) {
                True ->
                  "bg-blue-600 text-white hover:bg-blue-700 cursor-pointer"
                False -> "bg-gray-300 text-gray-500 cursor-not-allowed"
              },
            ),
            attribute.disabled(!is_valid_query(model.current_query)),
            event.on_click(models.SearchArticles(model.current_query)),
          ],
          [element.text("Search")],
        ),
      ]),
      case is_valid_query(model.current_query) {
        True -> element.none()
        False ->
          html.p([attribute.class("text-red-600 text-sm mt-2")], [
            element.text(get_query_error(model.current_query)),
          ])
      },
      html.div([attribute.class("flex flex-wrap gap-4 items-center")], [
        html.label([attribute.class("font-semibold text-gray-700")], [
          element.text("Filter by country:"),
        ]),
        html.div([attribute.class("flex flex-wrap gap-2")], [
          view_country_button(model, "us", "US"),
          view_country_button(model, "gb", "UK"),
          view_country_button(model, "ca", "CA"),
          view_country_button(model, "de", "DE"),
          view_country_button(model, "fr", "FR"),
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
    _, False, _ -> view_articles(model)
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
    [
      attribute.class(
        "bg-red-50 border border-red-200 rounded-lg p-6 my-8 max-w-2xl",
      ),
    ],
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
    [
      attribute.class(
        "text-center py-16 bg-gradient-to-br from-gray-50 to-gray-100 rounded-lg",
      ),
    ],
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
fn view_articles(model: models.Model) -> Element(models.Msg) {
  let count_text = case model.total_results {
    0 -> "Latest Articles"
    count -> "Latest Articles (" <> int.to_string(count) <> " results)"
  }
  html.section([], [
    html.h2([attribute.class("text-3xl font-bold text-gray-900 mb-8")], [
      element.text(count_text),
    ]),
    html.div(
      [attribute.class("grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6")],
      list.map(model.articles, view_article),
    ),
    view_pagination(model),
  ])
}

// Render single article
fn view_article(article: models.Article) -> Element(models.Msg) {
  html.article(
    [
      attribute.class(
        "article-card bg-white rounded-lg overflow-hidden shadow border border-gray-200",
      ),
    ],
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
        [
          attribute.class(
            "w-full h-48 bg-gradient-to-br from-gray-200 to-gray-300 flex items-center justify-center",
          ),
        ],
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
      [
        attribute.class(
          "inline-block bg-blue-100 text-blue-800 text-xs font-semibold px-3 py-1 rounded-full",
        ),
      ],
      [element.text(source.name)],
    ),
  ])
}

// Render article metadata (author, date)
fn view_article_meta(article: models.Article) -> Element(models.Msg) {
  html.div(
    [
      attribute.class(
        "mt-auto pt-4 border-t border-gray-200 text-sm text-gray-600",
      ),
    ],
    [
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
    ],
  )
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

// Render country filter button
fn view_country_button(
  model: models.Model,
  country_code: String,
  label: String,
) -> Element(models.Msg) {
  let is_active = model.current_country == country_code
  html.button(
    [
      attribute.class(
        "px-4 py-2 rounded-lg font-semibold transition-colors "
        <> case is_active {
          True -> "bg-blue-600 text-white hover:bg-blue-700"
          False ->
            "bg-white text-gray-700 border border-gray-300 hover:bg-gray-50"
        },
      ),
      event.on_click(models.LoadTopHeadlines(country_code)),
    ],
    [element.text(label)],
  )
}

// Validation helpers
fn is_valid_query(query: String) -> Bool {
  let trimmed = string.trim(query)
  string.length(trimmed) > 0 && string.length(trimmed) >= 2
}

fn get_query_error(query: String) -> String {
  let trimmed = string.trim(query)
  case string.length(trimmed) {
    0 -> "Search query cannot be empty"
    1 -> "Search query must be at least 2 characters"
    _ -> ""
  }
}

// Render search results page
fn view_search_results(
  model: models.Model,
  query: String,
) -> Element(models.Msg) {
  html.div([], [
    html.h2([attribute.class("text-3xl font-bold text-gray-900 mb-8")], [
      element.text("Search Results for: " <> query),
    ]),
    view_content(model),
  ])
}

// Render headlines by country page
fn view_headlines_results(
  model: models.Model,
  country: String,
) -> Element(models.Msg) {
  html.div([], [
    html.h2([attribute.class("text-3xl font-bold text-gray-900 mb-8")], [
      element.text("Top Headlines - " <> string.uppercase(country)),
    ]),
    view_content(model),
  ])
}

// Render headlines by sources page
fn view_sources_results(
  model: models.Model,
  sources: String,
) -> Element(models.Msg) {
  html.div([], [
    html.h2([attribute.class("text-3xl font-bold text-gray-900 mb-8")], [
      element.text("Headlines from Sources: " <> sources),
    ]),
    view_content(model),
  ])
}

// Render 404 not found page
fn view_not_found() -> Element(models.Msg) {
  html.div([attribute.class("text-center py-16")], [
    html.h2([attribute.class("text-4xl font-bold text-gray-900 mb-4")], [
      element.text("404 - Page Not Found"),
    ]),
    html.p([attribute.class("text-gray-600 text-lg")], [
      element.text("The page you're looking for doesn't exist."),
    ]),
  ])
}

// Render pagination controls
fn view_pagination(model: models.Model) -> Element(models.Msg) {
  html.div(
    [attribute.class("flex justify-center items-center gap-4 mt-12 mb-8")],
    [
      html.button(
        [
          attribute.class(
            "px-4 py-2 rounded-lg font-semibold transition-colors "
            <> case model.current_page {
              1 ->
                "bg-gray-300 text-gray-500 cursor-not-allowed"
              _ ->
                "bg-blue-600 text-white hover:bg-blue-700 cursor-pointer"
            },
          ),
          attribute.disabled(model.current_page == 1),
          event.on_click(models.GoToPage(model.current_page - 1)),
        ],
        [element.text("← Previous")],
      ),
      html.span([attribute.class("text-gray-700 font-semibold")], [
        element.text("Page " <> int.to_string(model.current_page)),
      ]),
      html.button(
        [
          attribute.class(
            "px-4 py-2 rounded-lg font-semibold transition-colors bg-blue-600 text-white hover:bg-blue-700 cursor-pointer",
          ),
          event.on_click(models.GoToPage(model.current_page + 1)),
        ],
        [element.text("Next →")],
      ),
    ],
  )
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

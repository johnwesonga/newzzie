import routes.{type Route}

pub type Source {
  Source(id: String, name: String)
}

pub type Article {
  Article(
    source: Source,
    author: String,
    title: String,
    description: String,
    url: String,
    url_to_image: String,
    published_at: String,
    content: String,
  )
}

// Application state model
pub type Model {
  Model(
    articles: List(Article),
    total_results: Int,
    loading: Bool,
    error: String,
    current_query: String,
    current_country: String,
    route: Route,
  )
}

// Application messages
pub type Msg {
  UserNavigatedTo(Route)
  SearchQueryChanged(String)
  SearchArticles(String)
  LoadTopHeadlines(String)
  LoadHeadlinesBySources(String)
  LoadHeadlines
  ArticlesLoaded(List(Article), Int)
  HeadlinesFailed(String)
}

// Initialize the application with empty state
pub fn init() -> Model {
  Model(
    articles: [],
    total_results: 0,
    loading: False,
    error: "",
    current_query: "",
    current_country: "us",
    route: routes.Home,
  )
}

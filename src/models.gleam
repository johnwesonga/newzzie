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
    loading: Bool,
    error: String,
    current_query: String,
    current_country: String,
  )
}

// Application messages
pub type Msg {
  SearchQueryChanged(String)
  SearchArticles(String)
  LoadTopHeadlines(String)
  LoadHeadlines
  ArticlesLoaded(List(Article))
  HeadlinesFailed(String)
}

// Initialize the application with empty state
pub fn init() -> Model {
  Model(
    articles: [],
    loading: False,
    error: "",
    current_query: "",
    current_country: "us",
  )
}

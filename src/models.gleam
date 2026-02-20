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

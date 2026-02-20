import lustre
import models
import views

pub fn main() -> Nil {
  let app = lustre.simple(init, update, views.view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

// Initialize the application state
fn init(_: Nil) -> models.Model {
  models.init()
}

// Handle application messages and update state
fn update(model: models.Model, msg: models.Msg) -> models.Model {
  case msg {
    models.SearchQueryChanged(query) ->
      models.Model(..model, current_query: query)
    models.SearchArticles(query) ->
      models.Model(..model, current_query: query, loading: True)
    models.LoadTopHeadlines(country) ->
      models.Model(..model, current_country: country, loading: True)
    models.LoadHeadlines ->
      models.Model(..model, loading: True)
    models.ArticlesLoaded(articles) ->
      models.Model(..model, articles: articles, loading: False, error: "")
    models.HeadlinesFailed(error) ->
      models.Model(..model, loading: False, error: error)
  }
}

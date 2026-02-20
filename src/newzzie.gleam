import lustre
import lustre/effect
import api
import models
import views

pub fn main() -> Nil {
  let app = lustre.application(init, update, views.view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

// Initialize the application state
fn init(_: Nil) -> #(models.Model, effect.Effect(models.Msg)) {
  #(models.init(), effect.none())
}

// Handle application messages and update state
fn update(
  model: models.Model,
  msg: models.Msg,
) -> #(models.Model, effect.Effect(models.Msg)) {
  case msg {
    models.SearchQueryChanged(query) ->
      #(models.Model(..model, current_query: query), effect.none())
    models.SearchArticles(query) -> {
      let updated = models.Model(..model, current_query: query, loading: True)
      let api_effect = api.everything(
        query,
        "YOUR_API_KEY_HERE",
        fn(result) {
          case result {
            Ok(articles) -> models.ArticlesLoaded(articles)
            Error(_) ->
              models.HeadlinesFailed(
                "Failed to fetch articles. Please try again.",
              )
          }
        },
      )
      #(updated, api_effect)
    }
    models.LoadTopHeadlines(country) -> {
      let updated =
        models.Model(..model, current_country: country, loading: True)
      #(updated, effect.none())
    }
    models.LoadHeadlines ->
      #(models.Model(..model, loading: True), effect.none())
    models.ArticlesLoaded(articles) ->
      #(
        models.Model(..model, articles: articles, loading: False, error: ""),
        effect.none(),
      )
    models.HeadlinesFailed(error) ->
      #(models.Model(..model, loading: False, error: error), effect.none())
  }
}

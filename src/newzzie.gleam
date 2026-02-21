import api
import gleam/list
import lustre
import lustre/effect
import models
import views

pub fn main() -> Nil {
  let app = lustre.application(init, update, views.view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

// Initialize the application state
fn init(_: Nil) -> #(models.Model, effect.Effect(models.Msg)) {
   let initial_model = models.init()
   let api_effect =
     api.top_headlines("us", "a688e6494c444902b1fc9cb93c61d697", fn(result) {
       case result {
         Ok(articles) -> models.ArticlesLoaded(articles, list.length(articles))
         Error(_) ->
           models.HeadlinesFailed(
             "Failed to fetch headlines. Please try again.",
           )
       }
     })
   #(initial_model, api_effect)
 }

// Handle application messages and update state
fn update(
  model: models.Model,
  msg: models.Msg,
) -> #(models.Model, effect.Effect(models.Msg)) {
  case msg {
    models.SearchQueryChanged(query) -> #(
      models.Model(..model, current_query: query),
      effect.none(),
    )
    models.SearchArticles(query) -> {
      let updated = models.Model(..model, current_query: query, loading: True)
      let api_effect =
        api.everything(query, "a688e6494c444902b1fc9cb93c61d697", fn(result) {
          case result {
            Ok(articles) ->
              models.ArticlesLoaded(articles, list.length(articles))
            Error(_) ->
              models.HeadlinesFailed(
                "Failed to fetch articles. Please try again.",
              )
          }
        })
      #(updated, api_effect)
    }
    models.LoadTopHeadlines(country) -> {
      let updated =
        models.Model(..model, current_country: country, loading: True)
      let api_effect =
        api.top_headlines(
          country,
          "a688e6494c444902b1fc9cb93c61d697",
          fn(result) {
            case result {
              Ok(articles) ->
                models.ArticlesLoaded(articles, list.length(articles))
              Error(_) ->
                models.HeadlinesFailed(
                  "Failed to fetch headlines. Please try again.",
                )
            }
          },
        )
      #(updated, api_effect)
    }
    models.LoadHeadlines -> #(
      models.Model(..model, loading: True),
      effect.none(),
    )
    models.ArticlesLoaded(articles, count) -> #(
      models.Model(
        ..model,
        articles: articles,
        total_results: count,
        loading: False,
        error: "",
      ),
      effect.none(),
    )
    models.HeadlinesFailed(error) -> #(
      models.Model(..model, loading: False, error: error),
      effect.none(),
    )
  }
}

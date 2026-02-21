import api
import gleam/list
import gleam/string
import lustre
import lustre/effect
import modem
import models
import routes
import views

pub fn main() -> Nil {
  let app = lustre.application(init, update, views.view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

// Initialize the application state
fn init(_: Nil) -> #(models.Model, effect.Effect(models.Msg)) {
   let route = case modem.initial_uri() {
     Ok(uri) -> routes.parse_route(uri)
     Error(_) -> routes.Home
   }

   let initial_model = models.Model(..models.init(), route: route)

   let effects = [
     modem.init(fn(uri) {
       uri
       |> routes.parse_route
       |> models.UserNavigatedTo
     }),
     api_effect_for_home(),
   ]

   #(initial_model, effect.batch(effects))
 }

 fn api_effect_for_home() -> effect.Effect(models.Msg) {
   api.top_headlines("us", "a688e6494c444902b1fc9cb93c61d697", fn(result) {
     case result {
       Ok(articles) -> models.ArticlesLoaded(articles, list.length(articles))
       Error(_) ->
         models.HeadlinesFailed(
           "Failed to fetch headlines. Please try again.",
         )
     }
   })
 }

// Handle application messages and update state
fn update(
  model: models.Model,
  msg: models.Msg,
) -> #(models.Model, effect.Effect(models.Msg)) {
  case msg {
    models.UserNavigatedTo(route) -> #(
      models.Model(..model, route: route),
      effect.none(),
    )
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
    models.LoadHeadlinesBySources(sources_str) -> {
      let updated = models.Model(..model, loading: True)
      let sources_list = string.split(sources_str, ",")
      let api_effect =
        api.top_headlines_by_source(
          sources_list,
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

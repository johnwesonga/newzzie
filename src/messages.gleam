import api
import gleam/list
import gleam/string
import lustre/effect
import models
import routes

/// Handles all application messages and returns the updated model with effects.
///
/// Dispatches to appropriate handlers based on message type and manages
/// side effects like API calls. This is the central update function for
/// the entire application.
///
/// # Parameters
///
/// - `model` - The current application state
/// - `msg` - The message to handle
///
/// # Returns
///
/// A tuple of the updated model and any side effects to execute
pub fn update(
  model: models.Model,
  msg: models.Msg,
) -> #(models.Model, effect.Effect(models.Msg)) {
  case msg {
    models.UserNavigatedTo(route) -> handle_user_navigated_to(model, route)

    models.SearchQueryChanged(query) ->
      handle_search_query_changed(model, query)

    models.SearchArticles(query) -> handle_search_articles(model, query)

    models.LoadTopHeadlines(country) ->
      handle_load_top_headlines(model, country)

    models.LoadHeadlinesBySources(sources_str) ->
      handle_load_headlines_by_sources(model, sources_str)

    models.LoadHeadlines -> handle_load_headlines(model)

    models.ArticlesLoaded(articles, count) ->
      handle_articles_loaded(model, articles, count)

    models.HeadlinesFailed(error) -> handle_headlines_failed(model, error)

    models.GoToPage(page) -> handle_go_to_page(model, page)
  }
}

/// Handles navigation to a new route.
fn handle_user_navigated_to(
  model: models.Model,
  route: routes.Route,
) -> #(models.Model, effect.Effect(models.Msg)) {
  #(models.Model(..model, route: route), effect.none())
}

/// Handles changes to the search query input field.
fn handle_search_query_changed(
  model: models.Model,
  query: String,
) -> #(models.Model, effect.Effect(models.Msg)) {
  #(models.Model(..model, current_query: query), effect.none())
}

/// Handles article search requests with API call.
fn handle_search_articles(
  model: models.Model,
  query: String,
) -> #(models.Model, effect.Effect(models.Msg)) {
  let updated =
    models.Model(..model, current_query: query, loading: True, current_page: 1)
  let api_effect =
    api.everything(query, 1, fn(result) {
      case result {
        Ok(articles) -> models.ArticlesLoaded(articles, list.length(articles))
        Error(_) ->
          models.HeadlinesFailed("Failed to fetch articles. Please try again.")
      }
    })
  #(updated, api_effect)
}

/// Handles top headlines requests by country with API call.
fn handle_load_top_headlines(
  model: models.Model,
  country: String,
) -> #(models.Model, effect.Effect(models.Msg)) {
  let updated =
    models.Model(
      ..model,
      current_country: country,
      loading: True,
      current_page: 1,
    )
  let api_effect =
    api.top_headlines(country, 1, fn(result) {
      case result {
        Ok(articles) -> models.ArticlesLoaded(articles, list.length(articles))
        Error(_) ->
          models.HeadlinesFailed("Failed to fetch headlines. Please try again.")
      }
    })
  #(updated, api_effect)
}

/// Handles headlines by sources requests with API call.
fn handle_load_headlines_by_sources(
  model: models.Model,
  sources_str: String,
) -> #(models.Model, effect.Effect(models.Msg)) {
  let updated = models.Model(..model, loading: True, current_page: 1)
  let sources_list = string.split(sources_str, ",")
  let api_effect =
    api.top_headlines_by_source(
      sources_list,
      1,
      fn(result) {
        case result {
          Ok(articles) -> models.ArticlesLoaded(articles, list.length(articles))
          Error(_) ->
            models.HeadlinesFailed(
              "Failed to fetch headlines. Please try again.",
            )
        }
      },
    )
  #(updated, api_effect)
}

/// Handles loading headlines (placeholder handler).
fn handle_load_headlines(
  model: models.Model,
) -> #(models.Model, effect.Effect(models.Msg)) {
  #(models.Model(..model, loading: True), effect.none())
}

/// Handles successful article load completion.
fn handle_articles_loaded(
  model: models.Model,
  articles: List(models.Article),
  count: Int,
) -> #(models.Model, effect.Effect(models.Msg)) {
  #(
    models.Model(
      ..model,
      articles: articles,
      total_results: count,
      loading: False,
      error: "",
    ),
    effect.none(),
  )
}

/// Handles article load failure with error message.
fn handle_headlines_failed(
  model: models.Model,
  error: String,
) -> #(models.Model, effect.Effect(models.Msg)) {
  #(models.Model(..model, loading: False, error: error), effect.none())
}

/// Handles pagination navigation.
fn handle_go_to_page(
  model: models.Model,
  page: Int,
) -> #(models.Model, effect.Effect(models.Msg)) {
  let updated = models.Model(..model, loading: True, current_page: page)

  // Determine which API to call based on current query/country
  let api_effect = case model.current_query {
    "" ->
      // No active search, use top headlines
      api.top_headlines(model.current_country, page, fn(result) {
        case result {
          Ok(articles) -> models.ArticlesLoaded(articles, list.length(articles))
          Error(_) ->
            models.HeadlinesFailed("Failed to fetch headlines. Please try again.")
        }
      })
    query ->
      // Active search query, use search
      api.everything(query, page, fn(result) {
        case result {
          Ok(articles) -> models.ArticlesLoaded(articles, list.length(articles))
          Error(_) ->
            models.HeadlinesFailed("Failed to fetch articles. Please try again.")
        }
      })
  }

  #(updated, api_effect)
}

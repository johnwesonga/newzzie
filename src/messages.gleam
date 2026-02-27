import api
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import lustre/effect
import models
import routes
import session
import storage

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

    models.ArticlesLoaded(articles, count, json_str) ->
      handle_articles_loaded(model, articles, count, json_str)

    models.HeadlinesFailed(error) -> handle_headlines_failed(model, error)

    models.GoToPage(page) -> handle_go_to_page(model, page)

    models.CachedArticlesLoaded(articles, count) ->
      handle_cached_articles_loaded(model, articles, count)
  }
}

/// Builds a model updated with context extracted from the given route.
/// Sets route, current_query, current_country, current_page, and loading
/// state appropriately so both init and navigation share consistent behaviour.
pub fn model_for_route(
  model: models.Model,
  route: routes.Route,
) -> models.Model {
  case route {
    routes.Search(query, page) ->
      models.Model(
        ..model,
        route: route,
        current_query: query,
        current_page: page,
        loading: True,
      )
    routes.Headlines(country, page) ->
      models.Model(
        ..model,
        route: route,
        current_country: country,
        current_page: page,
        loading: True,
      )
    routes.HeadlinesBySources(_sources, page) ->
      models.Model(..model, route: route, current_page: page, loading: True)
    _ -> models.Model(..model, route: route)
  }
}

/// Returns the API effect required to load data for the given route.
/// Returns effect.none() for routes that don't fetch data (Home, About, etc.).
pub fn effect_for_route(route: routes.Route) -> effect.Effect(models.Msg) {
  case route {
    routes.Search(query, page) -> {
      io.println(
        "[Messages] Fetching search results for: "
        <> query
        <> " page "
        <> int.to_string(page),
      )
      api.everything(query, page, fn(result) {
        case result {
          Ok(#(articles, json_str)) ->
            models.ArticlesLoaded(articles, list.length(articles), json_str)
          Error(_) ->
            models.HeadlinesFailed(
              "Failed to fetch articles. Please try again.",
            )
        }
      })
    }
    routes.Headlines(country, page) -> {
      io.println(
        "[Messages] Fetching headlines for: "
        <> country
        <> " page "
        <> int.to_string(page),
      )
      api.top_headlines(country, page, fn(result) {
        case result {
          Ok(#(articles, json_str)) ->
            models.ArticlesLoaded(articles, list.length(articles), json_str)
          Error(_) ->
            models.HeadlinesFailed(
              "Failed to fetch headlines. Please try again.",
            )
        }
      })
    }
    routes.HeadlinesBySources(sources_str, page) -> {
      io.println(
        "[Messages] Fetching headlines by sources: "
        <> sources_str
        <> " page "
        <> int.to_string(page),
      )
      let sources_list = string.split(sources_str, ",")
      api.top_headlines_by_source(sources_list, page, fn(result) {
        case result {
          Ok(#(articles, json_str)) ->
            models.ArticlesLoaded(articles, list.length(articles), json_str)
          Error(_) ->
            models.HeadlinesFailed(
              "Failed to fetch headlines. Please try again.",
            )
        }
      })
    }
    _ -> effect.none()
  }
}

/// Handles navigation to a new route.
fn handle_user_navigated_to(
  model: models.Model,
  route: routes.Route,
) -> #(models.Model, effect.Effect(models.Msg)) {
  io.println("[Messages] Navigating to route from URL")
  let updated_model = model_for_route(model, route)
  session.save_state(updated_model)
  #(updated_model, effect_for_route(route))
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
  let new_route = routes.Search(query, 1)
  let updated =
    models.Model(
      ..model,
      current_query: query,
      loading: True,
      current_page: 1,
      route: new_route,
    )
  session.navigate_to(routes.route_to_path(new_route))
  let api_effect =
    api.everything(query, 1, fn(result) {
      case result {
        Ok(#(articles, json_str)) ->
          models.ArticlesLoaded(articles, list.length(articles), json_str)
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
  let new_route = routes.Headlines(country, 1)
  let updated =
    models.Model(
      ..model,
      current_country: country,
      loading: True,
      current_page: 1,
      route: new_route,
    )
  session.navigate_to(routes.route_to_path(new_route))
  let api_effect =
    api.top_headlines(country, 1, fn(result) {
      case result {
        Ok(#(articles, json_str)) ->
          models.ArticlesLoaded(articles, list.length(articles), json_str)
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
    api.top_headlines_by_source(sources_list, 1, fn(result) {
      case result {
        Ok(#(articles, json_str)) ->
          models.ArticlesLoaded(articles, list.length(articles), json_str)
        Error(_) ->
          models.HeadlinesFailed("Failed to fetch headlines. Please try again.")
      }
    })
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
  json_str: String,
) -> #(models.Model, effect.Effect(models.Msg)) {
  // Cache articles for future retrieval
  let cache_key = case model.current_query {
    "" -> storage.headlines_cache_key(model.current_country, model.current_page)
    query -> storage.search_cache_key(query, model.current_page)
  }
  storage.cache_articles(cache_key, json_str)

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
  io.println("[Messages] Navigating to page " <> int.to_string(page))

  // Update route to include page number
  let updated_route = case model.route {
    routes.Search(query, _) -> routes.Search(query, page)
    routes.Headlines(country, _) -> routes.Headlines(country, page)
    routes.HeadlinesBySources(sources, _) ->
      routes.HeadlinesBySources(sources, page)
    _ -> model.route
  }

  let updated =
    models.Model(
      ..model,
      loading: True,
      current_page: page,
      route: updated_route,
    )

  // Update browser URL and save state
  session.navigate_to(routes.route_to_path(updated_route))
  session.save_state(updated)

  // Try to load from cache first
  let cache_key = case model.current_query {
    "" -> storage.headlines_cache_key(model.current_country, page)
    query -> storage.search_cache_key(query, page)
  }
  io.println("[Messages] Generated cache key: " <> cache_key)

  case storage.get_cached_articles(cache_key) {
    Ok(_) -> {
      // Cache exists, fetch fresh data to stay current
      // In future, could implement smart cache validation
      let api_effect = case model.current_query {
        "" ->
          // No active search, use top headlines
          api.top_headlines(model.current_country, page, fn(result) {
            case result {
              Ok(#(articles, json_str)) ->
                models.ArticlesLoaded(articles, list.length(articles), json_str)
              Error(_) ->
                models.HeadlinesFailed(
                  "Failed to fetch headlines. Please try again.",
                )
            }
          })
        query ->
          // Active search query, use search
          api.everything(query, page, fn(result) {
            case result {
              Ok(#(articles, json_str)) ->
                models.ArticlesLoaded(articles, list.length(articles), json_str)
              Error(_) ->
                models.HeadlinesFailed(
                  "Failed to fetch articles. Please try again.",
                )
            }
          })
      }

      #(updated, api_effect)
    }
    Error(_) -> {
      // Cache miss, fetch from API
      let api_effect = case model.current_query {
        "" ->
          // No active search, use top headlines
          api.top_headlines(model.current_country, page, fn(result) {
            case result {
              Ok(#(articles, json_str)) ->
                models.ArticlesLoaded(articles, list.length(articles), json_str)
              Error(_) ->
                models.HeadlinesFailed(
                  "Failed to fetch headlines. Please try again.",
                )
            }
          })
        query ->
          // Active search query, use search
          api.everything(query, page, fn(result) {
            case result {
              Ok(#(articles, json_str)) ->
                models.ArticlesLoaded(articles, list.length(articles), json_str)
              Error(_) ->
                models.HeadlinesFailed(
                  "Failed to fetch articles. Please try again.",
                )
            }
          })
      }

      #(updated, api_effect)
    }
  }
}

/// Handles loading cached articles.
fn handle_cached_articles_loaded(
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

import lustre
import lustre/effect
import messages
import models
import modem
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

  // Only load default headlines if on home route; other routes will load their own data via UserNavigatedTo
  let default_effect = case route {
    routes.Home -> api_effect_for_home()
    _ -> effect.none()
  }

  let effects = [
    modem.init(fn(uri) {
      uri
      |> routes.parse_route
      |> models.UserNavigatedTo
    }),
    default_effect,
  ]

  #(initial_model, effect.batch(effects))
}

fn api_effect_for_home() -> effect.Effect(models.Msg) {
  let load_headlines = models.LoadTopHeadlines("us")
  messages.update(models.init(), load_headlines)
  |> fn(result) { result.1 }
}

// Handle application messages and update state
fn update(
  model: models.Model,
  msg: models.Msg,
) -> #(models.Model, effect.Effect(models.Msg)) {
  messages.update(model, msg)
}

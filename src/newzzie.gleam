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

  // Dispatch UserNavigatedTo for the initial route to load appropriate data
  let initial_navigation_effect =
    effect.from(fn(dispatch) { dispatch(models.UserNavigatedTo(route)) })

  let effects = [
    modem.init(fn(uri) {
      uri
      |> routes.parse_route
      |> models.UserNavigatedTo
    }),
    initial_navigation_effect,
  ]

  #(initial_model, effect.batch(effects))
}

// Handle application messages and update state
fn update(
  model: models.Model,
  msg: models.Msg,
) -> #(models.Model, effect.Effect(models.Msg)) {
  messages.update(model, msg)
}

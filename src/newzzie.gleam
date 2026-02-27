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

  let initial_model = messages.model_for_route(models.init(), route)

  let router_effect =
    modem.init(fn(uri) {
      uri
      |> routes.parse_route
      |> models.UserNavigatedTo
    })

  let load_effect = messages.effect_for_route(route)

  #(initial_model, effect.batch([router_effect, load_effect]))
}

// Handle application messages and update state
fn update(
  model: models.Model,
  msg: models.Msg,
) -> #(models.Model, effect.Effect(models.Msg)) {
  messages.update(model, msg)
}

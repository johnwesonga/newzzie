import lustre
import lustre/element/html

pub fn main() -> Nil {
  let app =
    lustre.element(
      html.div([], [
        html.text("Welcome to Newzzie!"),
      ]),
    )
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

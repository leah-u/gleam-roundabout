import birdie
import glam/doc
import roundabout/fixtures
import roundabout/generate_helpers

pub fn generate_helpers_rec_test() {
  let root = fixtures.fixture_root()

  let actual =
    generate_helpers.generate_helpers_rec([], root)
    |> doc.to_string(80)

  actual
  |> birdie.snap(title: "generate_helpers_rec")
}

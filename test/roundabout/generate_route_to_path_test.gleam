import birdie
import glam/doc
import roundabout/fixtures
import roundabout/generate_route_to_path

/// generate_route_to_path
///
pub fn generate_route_to_path_root_test() {
  let root = fixtures.fixture_root()

  let actual =
    generate_route_to_path.generate_route_to_path([], root)
    |> doc.to_string(80)

  actual
  |> birdie.snap(title: "generate_route_to_path_root")
}

pub fn generate_route_to_path_rec_test() {
  let root = fixtures.fixture_root()

  let actual =
    generate_route_to_path.generate_route_to_path_rec([], root)
    |> doc.to_string(80)

  actual
  |> birdie.snap(title: "generate_route_to_path_rec")
}

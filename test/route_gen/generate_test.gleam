import birdie
import gleam/list
import route_gen/generate
import route_gen/parse
import route_gen/types

const routes = [
  types.InputDef(name: "home", path: [], sub: []),
  types.InputDef(name: "clients", path: [types.Lit("clients")], sub: []),
  types.InputDef(
    name: "client",
    path: [types.Lit("clients"), types.Int("clientId")],
    sub: [
      types.InputDef(name: "show", path: [], sub: []),
      types.InputDef(
        name: "orders",
        path: [types.Lit("orders")],
        sub: [
          types.InputDef(name: "index", path: [], sub: []),
          types.InputDef(name: "show", path: [types.Int("orderId")], sub: []),
        ],
      ),
    ],
  ),
]

pub fn get_type_name_test() {
  let actual =
    generate.get_type_name(
      [types.Info(name: "client", segments: [])],
      types.Info(name: "simpleUser", segments: []),
    )

  assert actual == "ClientSimpleUser"
}

pub fn get_function_name_test() {
  let actual =
    generate.get_function_name(
      [types.Info(name: "client", segments: [])],
      types.Info(name: "simpleUser", segments: []),
    )

  assert actual == "client_simple_user"
}

pub fn generate_type_rec_test() {
  let assert Ok(root) = parse.parse(routes)

  let assert Ok(actual) = generate.generate_type_rec([], root)

  actual
  |> birdie.snap(title: "generate_type_rec")
}

pub fn generate_segments_to_route_rec_test() {
  let assert Ok(root) = parse.parse(routes)

  let assert Ok(actual) = generate.generate_segments_to_route_rec([], root)

  actual
  |> birdie.snap(title: "generate_segments_to_route_rec")
}

pub fn generate_route_to_path_rec_test() {
  let assert Ok(root) = parse.parse(routes)

  let assert Ok(actual) = generate.generate_route_to_path_rec([], root)

  actual
  |> birdie.snap(title: "generate_route_to_path_rec")
}

pub fn generate_helpers_rec_test() {
  let assert Ok(root) = parse.parse(routes)

  let actual = generate.generate_helpers_rec([], root)

  actual
  |> birdie.snap(title: "generate_helpers_rec")
}

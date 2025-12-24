import gleam/list
import gleam/option
import gleam/result
import gleam/set
import gleam/string
import justin
import route_gen/types.{type Info, type InputDef, type Node, Info, Node}

@internal
pub fn parse(definitions: List(InputDef)) {
  use contributions <- result.try(prepare_contributions(
    option.None,
    definitions,
  ))

  let root =
    types.Node(
      children: contributions,
      info: types.Info(name: "", ancestor: option.None, segments: []),
    )

  Ok(root)
}

@internal
pub fn prepare_contributions(
  ancestor: option.Option(Info),
  definitions: List(InputDef),
) -> Result(List(Node), String) {
  use contributions <- result.try(
    list.try_map(definitions, prepare_contribution(ancestor, _)),
  )

  use contributions <- result.try(assert_no_duplicate_variant_names(
    contributions,
  ))

  Ok(contributions)
}

fn assert_no_duplicate_variant_names(contributions: List(Node)) {
  let variant_names =
    list.map(contributions, fn(item) { justin.snake_case(item.info.name) })

  let as_set = set.from_list(variant_names)

  case list.length(variant_names) == set.size(as_set) {
    True -> Ok(contributions)
    False -> Error("Routes contain duplicate names")
  }
}

@internal
pub fn prepare_contribution(ancestor: option.Option(Info), definition: InputDef) {
  let info = prepare_contribution_info(ancestor, definition)

  use children <- result.try(prepare_contributions(
    option.Some(info),
    definition.sub,
  ))

  Node(info:, children:) |> Ok
}

@internal
pub fn prepare_contribution_info(
  ancestor: option.Option(Info),
  definition: InputDef,
) {
  Info(ancestor:, name: definition.name, segments: definition.path)
}

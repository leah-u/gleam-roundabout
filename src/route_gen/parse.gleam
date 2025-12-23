import gleam/list
import gleam/result
import gleam/set
import gleam/string
import justin
import route_gen/types.{
  type Contribution, type ContributionInfo, type InputDef, Contribution,
  ContributionInfo,
}

@internal
pub fn prepare_contributions(
  ancestors: List(ContributionInfo),
  definitions: List(InputDef),
) -> Result(List(Contribution), String) {
  use contributions <- result.try(
    list.try_map(definitions, prepare_contribution(ancestors, _)),
  )

  use contributions <- result.try(assert_no_duplicate_variant_names(
    contributions,
  ))

  Ok(contributions)
}

fn assert_no_duplicate_variant_names(contributions: List(Contribution)) {
  let variant_names = list.map(contributions, fn(item) { item.info.type_name })

  let as_set = set.from_list(variant_names)

  case list.length(variant_names) == set.size(as_set) {
    True -> Ok(contributions)
    False -> Error("Routes contain duplicate names")
  }
}

@internal
pub fn prepare_contribution(
  ancestors: List(ContributionInfo),
  definition: InputDef,
) {
  let info = prepare_contribution_info(ancestors, definition)

  let children_ancestors = list.append(ancestors, [info])

  use children <- result.try(prepare_contributions(
    children_ancestors,
    definition.sub,
  ))

  Contribution(ancestors:, info:, children:) |> Ok
}

@internal
pub fn prepare_contribution_info(
  ancestors: List(ContributionInfo),
  definition: InputDef,
) {
  let ns_snake_name =
    ancestors
    |> list.map(fn(a) { a.snake_name })
    |> string.join("_")

  let snake_name = justin.snake_case(definition.name)

  let ns_type_name =
    ancestors
    |> list.map(fn(a) { a.type_name })
    |> string.join("")

  let type_name = justin.pascal_case(definition.name)

  let segment_params =
    definition.path
    |> list.filter_map(fn(segment) {
      case segment {
        types.Lit(_) -> Error(Nil)
        types.Int(name) -> Ok(types.Param(name, ns_snake_name, types.ParamInt))
        types.Str(name) -> Ok(types.Param(name, ns_snake_name, types.ParamStr))
      }
    })

  ContributionInfo(
    snake_name:,
    ns_snake_name:,
    type_name:,
    ns_type_name:,
    segment_params:,
  )
}

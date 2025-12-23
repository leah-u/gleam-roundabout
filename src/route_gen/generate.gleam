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
pub fn generate_helpers(contributions: List(Contribution)) {
  case list.is_empty(contributions) {
    True -> Error(Nil)
    False -> {
      let sub_types =
        list.filter_map(contributions, fn(contribution) {
          generate_helpers(contribution.children)
        })
        |> string.join("\n")

      let out =
        generate_helpers_for_contributions(contributions) <> "\n\n" <> sub_types

      Ok(out)
    }
  }
}

fn generate_helpers_for_contributions(contributions: List(Contribution)) {
  list.map(contributions, generate_helpers_for_contribution)
  |> string.join("")
}

fn generate_helpers_for_contribution(cont: Contribution) {
  "pub fn _path("
  generate_route_helper(cont)
}

@internal
pub fn generate_route_helper(cont: Contribution) {
  let fn_name = full_snake_name(cont.ancestors, cont.info) <> "_route"

  let full_path = list.append(cont.ancestors, [cont.info])

  let params =
    full_path
    |> list.flat_map(fn(cont) {
      cont.segment_params
      |> list.map(fn(param) {
        let type_ = case param.kind {
          types.ParamInt -> "Int"
          types.ParamStr -> "String"
        }

        param.namespace <> param.name <> ": " <> type_
      })
    })
    |> string.join(", ")

  let body =
    full_path
    |> list.reverse
    |> list.map(fn(cont) {
      let params =
        cont.segment_params
        |> list.map(fn(param) { param.namespace <> param.name })
        |> fn(entries) {
          case list.is_empty(cont.segment_params) {
            True -> entries
            False -> list.append(entries, ["_"])
          }
        }

      let params = case list.is_empty(params) {
        True -> ""
        False -> "(" <> string.join(params, ", ") <> ")"
      }

      cont.ns_type_name <> cont.type_name <> params
    })
    |> string.join(" |> ")

  "pub fn " <> fn_name <> "(" <> params <> ") {\n" <> body <> "\n" <> "}"
}

@internal
pub fn full_snake_name(
  ancestors: List(ContributionInfo),
  this: ContributionInfo,
) {
  ancestors
  |> list.map(fn(a) { a.snake_name })
  |> list.append([this.snake_name])
  |> string.join("_")
}
// @internal
// pub fn namespaced_segment_type_and_params(
//   namespaces: List(String),
//   acc: List(ContributionInfo),
//   items: List(ContributionInfo),
// ) {
//   case items {
//     [first, ..rest] -> {
//       let namespace =
//         list.append(namespaces, [first.snake_name])
//         |> string.join("_")

//       let entries =
//         list.map(first.segment_params, fn(param) {
//           case param {
//             types.ParamInt(name) -> types.ParamInt(namespace <> "_" <> name)
//             types.ParamStr(name) -> types.ParamStr(namespace <> "_" <> name)
//           }
//         })

//       let next_acc = list.append(acc, entries)

//       namespaced_segment_type_and_params(
//         list.append(namespaces, [first.snake_name]),
//         next_acc,
//         rest,
//       )
//     }
//     _ -> acc
//   }
// }

import glam/doc
import gleam/list
import gleam/string
import roundabout/node.{type Info}
import roundabout/type_name

pub const double_quote = "\""

pub const forward_slash = "\"/\""

/// Join two strings with <>
/// We allow breaking just before
pub fn string_join() {
  doc.flex_break(" ", "")
  |> doc.append(doc.from_string("<> "))
}

pub fn pipe_join() {
  doc.flex_break(" ", "")
  |> doc.append(doc.from_string("|> "))
}

pub fn case_arrow() {
  doc.from_string(" ->")
  |> doc.append(doc.flex_break(" ", ""))
}

@internal
pub fn get_function_name(ancestors: List(Info), info: Info) -> String {
  get_function_name_do([], ancestors, info)
  |> list.filter(fn(seg) { seg != "" })
  |> string.join("_")
}

fn get_function_name_do(
  collected: List(String),
  ancestors: List(Info),
  info: Info,
) {
  let next = list.prepend(collected, type_name.snake(info.name))

  case ancestors {
    [next_ancestor, ..rest_ancestors] -> {
      get_function_name_do(next, rest_ancestors, next_ancestor)
    }
    _ -> next
  }
}

@internal
pub fn get_type_name(ancestors: List(Info), info: Info) -> String {
  get_type_name_do([], ancestors, info)
  |> string.join("")
}

fn get_type_name_do(collected: List(String), ancestors: List(Info), info: Info) {
  let next = list.prepend(collected, type_name.name(info.name))

  case ancestors {
    [next_ancestor, ..rest_ancestors] -> {
      get_type_name_do(next, rest_ancestors, next_ancestor)
    }
    _ -> next
  }
}

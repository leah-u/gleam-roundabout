import filepath
import glam/doc
import gleam/bool
import gleam/dict
import gleam/list
import gleam/result
import gleam/set
import gleam/string
import justin
import roundabout/internal/constant
import roundabout/internal/generate_helpers
import roundabout/internal/generate_other
import roundabout/internal/generate_route_to_path
import roundabout/internal/generate_route_to_template
import roundabout/internal/generate_segments_to_route
import roundabout/internal/generate_types
import roundabout/internal/node
import roundabout/internal/parameter
import roundabout/internal/type_name
import simplifile
import tom

pub type Segment {
  Lit(val: String)
  Str(name: String)
  Int(name: String)
}

pub type Route {
  Route(name: String, path: List(Segment), sub: List(Route))
}

pub fn main() {
  let root = find_root("./")
  let src_path = filepath.join(root, "src")
  let assert Ok(gleam_toml) = simplifile.read(filepath.join(root, "gleam.toml"))
    as "Could not read 'gleam.toml'"

  let assert Ok(gleam_toml) = tom.parse(gleam_toml)
    as "Could not parse
  'gleam.toml'"
  let assert Ok(config) = tom.get_table(gleam_toml, ["tools", "roundabout"])
    as "Could not find the [tools.roundabout] section in 'gleam.toml'"
  let routers =
    dict.to_list(config)
    |> list.map(fn(router) {
      let #(router, config) = router
      let file = filepath.join(src_path, router)
      let file = case filepath.extension(file) {
        Error(Nil) -> file <> ".gleam"
        Ok(_) ->
          panic as {
            "Router may not contain a file extension: "
            <> router
            <> "\nUse '"
            <> filepath.strip_extension(router)
            <> "' instead"
          }
      }
      let assert Ok(routes) = tom.as_table(config)
        as "Router must be a TOML
      table"
      let routes =
        dict.to_list(routes)
        |> list.map(parse_route)
      #(file, routes)
    })

  list.each(routers, fn(router) {
    let #(output_path, definitions) = router
    let assert Ok(_) = generate(definitions, output_path)
  })
}

fn parse_path(path: String) -> Result(List(Segment), Nil) {
  use <- bool.guard(when: path == "", return: Ok([]))

  string.split(path, "/")
  |> list.try_map(fn(segment) {
    case segment {
      "{" <> segment -> {
        case string.split(segment, "}") {
          [segment, ""] -> {
            case string.split(segment, ":") {
              [name] | [name, "String"] -> Ok(Str(name))
              [name, "Int"] -> Ok(Int(name))
              _ -> Error(Nil)
            }
          }
          _ -> Error(Nil)
        }
      }
      _ -> Ok(Lit(segment))
    }
  })
}

fn parse_route(route: #(String, tom.Toml)) -> Route {
  let #(name, config) = route
  case config {
    tom.InlineTable(table) | tom.Table(table) -> {
      let prefix = case tom.get_string(table, ["__prefix"]) {
        Ok(prefix) -> prefix
        Error(tom.NotFound(..)) -> ""
        Error(tom.WrongType(..)) -> panic as "__prefix must be a string"
      }
      let assert Ok(path) = parse_path(prefix)
        as { "Invalid path: '" <> prefix <> "'" }
      let sub_routes =
        dict.delete(table, "__prefix")
        |> dict.to_list
        |> list.map(parse_route)

      Route(name:, path:, sub: sub_routes)
    }
    tom.String(path) -> {
      let assert Ok(path) = parse_path(path)
        as { "Invalid path: '" <> path <> "'" }
      let sub = []
      Route(name:, path:, sub:)
    }
    _ -> panic as { "Unexpected value" }
  }
}

fn find_root(path: String) -> String {
  case simplifile.is_file(filepath.join(path, "gleam.toml")) {
    Ok(True) -> path
    Ok(False) | Error(_) -> find_root(filepath.join(path, "../"))
  }
}

/// Generate the routes file
///
/// ```
/// roundabout.generate(route_definitions, "src/generated/routes")
/// ```
pub fn generate(definitions: List(Route), output_path: String) {
  use root <- result.try(parse(definitions))

  let output_path = case string.ends_with(output_path, ".gleam") {
    True -> output_path
    False -> output_path <> ".gleam"
  }

  let types = generate_types.generate_type_rec([], root)

  let segments_to_route =
    generate_segments_to_route.generate_segments_to_route_rec([], root)

  let routes_to_path =
    generate_route_to_path.generate_route_to_path_rec([], root)

  let routes_to_template =
    generate_route_to_template.generate_route_to_template_rec([], root)

  let helpers = generate_helpers.generate_helpers_rec([], root)

  let utils = generate_other.generate_utils()

  let all =
    doc.concat([
      generate_other.generate_header(),
      generate_other.generate_imports(),
      types,
      segments_to_route,
      routes_to_path,
      routes_to_template,
      helpers,
      utils,
    ])

  let generated_code = all |> doc.to_string(80)

  let output_dir = filepath.directory_name(output_path)
  let _ = simplifile.create_directory_all(output_dir)
  let _ = simplifile.write(output_path, generated_code)

  Ok(Nil)
}

@internal
pub fn parse(definitions: List(Route)) -> Result(node.Node, String) {
  use sub <- result.try(parse_definitions("root", definitions))

  let root =
    node.Node(sub:, info: node.Info(name: type_name.unsafe(""), path: []))

  Ok(root)
}

@internal
pub fn parse_definitions(
  parent_name: String,
  definitions: List(Route),
) -> Result(List(node.Node), String) {
  use nodes <- result.try(list.try_map(definitions, parse_definition))

  use nodes <- result.try(assert_no_duplicate_variant_names(parent_name, nodes))

  Ok(nodes)
}

fn assert_no_duplicate_variant_names(
  parent_name: String,
  nodes: List(node.Node),
) {
  let variant_names =
    list.map(nodes, fn(item) { type_name.snake(item.info.name) })

  let as_set = set.from_list(variant_names)

  case list.length(variant_names) == set.size(as_set) {
    True -> Ok(nodes)
    False -> Error("Route " <> parent_name <> " contain duplicate route names")
  }
}

fn parse_definition(definition: Route) {
  use info <- result.try(parse_definition_info(definition))

  use sub <- result.try(parse_definitions(definition.name, definition.sub))

  node.Node(info:, sub:) |> Ok
}

fn parse_definition_info(input: Route) {
  use input_path <- result.try(assert_no_duplicate_segment_names(
    input.name,
    input.path,
  ))

  let path_result =
    input_path
    |> list.try_map(fn(seg) {
      case seg {
        Lit(val) -> {
          constant.new(val)
          |> result.map(node.SegLit)
        }
        Str(val) -> {
          parameter.new(val, parameter.Str)
          |> result.map(node.SegParam)
        }
        Int(val) -> {
          parameter.new(val, parameter.Int)
          |> result.map(node.SegParam)
        }
      }
    })

  use name <- result.try(type_name.new(input.name))

  use path <- result.try(path_result)

  node.Info(name:, path:) |> Ok
}

fn assert_no_duplicate_segment_names(node_name: String, segments: List(Segment)) {
  let segment_names =
    list.filter_map(segments, fn(seg) {
      case seg {
        Lit(_) -> Error(Nil)
        Str(val) -> Ok(justin.snake_case(val))
        Int(val) -> Ok(justin.snake_case(val))
      }
    })

  let as_set = set.from_list(segment_names)

  case list.length(segment_names) == set.size(as_set) {
    True -> Ok(segments)
    False -> Error("Route " <> node_name <> " contain duplicate segment names")
  }
}

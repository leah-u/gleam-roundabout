import gleam/result
import route_gen/parameter_name.{new, to_string}

pub fn parameter_name_valid_test() {
  assert new("client_id") |> result.map(to_string) == Ok("client_id")

  assert new("clientId") |> result.map(to_string) == Ok("client_id")

  assert new("client id") |> result.map(to_string) == Ok("client_id")

  assert new("CLIENT_ID") |> result.map(to_string) == Ok("client_id")

  assert new("client123") |> result.map(to_string) == Ok("client123")

  assert new("client-id") |> result.map(to_string) == Ok("client_id")
}

pub fn parameter_name_invalid_test() {
  assert new("") == Error("Invalid parameter name ")

  assert new("client_@ID") == Error("Invalid parameter name client_@ID")

  assert new("123") == Error("Invalid parameter name 123")
}

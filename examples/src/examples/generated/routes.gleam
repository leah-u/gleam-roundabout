//// This module was generated using roundabout.
////

import gleam/int
import gleam/result

pub type Route {
  Comment(post_id: Int, comment_id: Int)
  Home
  MyOrders
  Order(id: Int)
  Profile(id: String)
  User(id: Int, sub: UserRoute)
}

pub type UserRoute {
  UserActivate
  UserShow
}

pub fn segments_to_route(segments: List(String)) -> Result(Route, Nil) {
  case segments {
    ["posts", post_id, "comments", comment_id] ->
      with_int(comment_id, fn(comment_id) { 
        with_int(post_id, fn(post_id) { 
          Comment(post_id, comment_id) |> Ok
         })
       })
    [] -> Home |> Ok
    ["my-orders"] -> MyOrders |> Ok
    ["orders", id] -> with_int(id, fn(id) { 
        Order(id) |> Ok
       })
    ["profile", id] -> Profile(id) |> Ok
    ["users", id, ..rest] -> with_int(id, fn(id) { 
        user_segments_to_route(rest) |> result.map(fn(sub) {
          User(id, sub)
        })
       })
    _ -> Error(Nil)
  }
}

fn user_segments_to_route(segments: List(String)) -> Result(UserRoute, Nil) {
  case segments {
    ["new"] -> UserActivate |> Ok
    [] -> UserShow |> Ok
    _ -> Error(Nil)
  }
}

pub fn route_to_path(route: Route) -> String {
  case route {
    Comment(post_id, comment_id) ->
      "/"
      <> "posts"
      <> "/"
      <> int.to_string(post_id)
      <> "/" <> "comments" <> "/" <> int.to_string(comment_id)
    Home -> "/"
    MyOrders -> "/" <> "my-orders"
    Order(id) -> "/" <> "orders" <> "/" <> int.to_string(id)
    Profile(id) -> "/" <> "profile" <> "/" <> id
    User(id, sub) ->
      "/" <> "users" <> "/" <> int.to_string(id) <> user_route_to_path(sub)
  }
}

fn user_route_to_path(route: UserRoute) -> String {
  case route {
    UserActivate -> "/" <> "new"
    UserShow -> ""
  }
}

pub fn route_to_template(route: Route) -> String {
  case route {
    Comment(..) ->
      "/"
      <> "posts"
      <> "/" <> "{post_id}" <> "/" <> "comments" <> "/" <> "{comment_id}"
    Home -> "/"
    MyOrders -> "/" <> "my-orders"
    Order(..) -> "/" <> "orders" <> "/" <> "{id}"
    Profile(..) -> "/" <> "profile" <> "/" <> "{id}"
    User(sub:, ..) ->
      "/" <> "users" <> "/" <> "{id}" <> user_route_to_template(sub)
  }
}

fn user_route_to_template(route: UserRoute) -> String {
  case route {
    UserActivate -> "/" <> "new"
    UserShow -> ""
  }
}

pub fn comment_route(comment_post_id: Int, comment_comment_id: Int) -> Route {
  Comment(comment_post_id, comment_comment_id)
}

pub fn comment_path(comment_post_id: Int, comment_comment_id: Int) -> String {
  comment_route(comment_post_id, comment_comment_id) |> route_to_path
}

pub fn home_route() -> Route {
  Home
}

pub fn home_path() -> String {
  home_route() |> route_to_path
}

pub fn my_orders_route() -> Route {
  MyOrders
}

pub fn my_orders_path() -> String {
  my_orders_route() |> route_to_path
}

pub fn order_route(order_id: Int) -> Route {
  Order(order_id)
}

pub fn order_path(order_id: Int) -> String {
  order_route(order_id) |> route_to_path
}

pub fn profile_route(profile_id: String) -> Route {
  Profile(profile_id)
}

pub fn profile_path(profile_id: String) -> String {
  profile_route(profile_id) |> route_to_path
}

pub fn user_activate_route(user_id: Int) -> Route {
  UserActivate |> User(user_id, _)
}

pub fn user_activate_path(user_id: Int) -> String {
  user_activate_route(user_id) |> route_to_path
}

pub fn user_show_route(user_id: Int) -> Route {
  UserShow |> User(user_id, _)
}

pub fn user_show_path(user_id: Int) -> String {
  user_show_route(user_id) |> route_to_path
}


fn with_int(str: String, fun) {
    int.parse(str)
    |> result.try(fun)
}

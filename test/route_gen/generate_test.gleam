import birdie
import route_gen/generate
import route_gen/types

pub fn generate_route_helper_test() {
  let contribution =
    types.Contribution(
      ancestors: [
        types.ContributionInfo(
          type_name: "Clients",
          ns_type_name: "",
          snake_name: "client",
          ns_snake_name: "",
          segment_params: [types.Param("id", "client", types.ParamInt)],
        ),
        types.ContributionInfo(
          type_name: "Orders",
          ns_type_name: "Clients",
          snake_name: "orders",
          ns_snake_name: "client",
          segment_params: [types.Param("id", "client", types.ParamStr)],
        ),
      ],
      children: [],
      info: types.ContributionInfo(
        type_name: "Track",
        ns_type_name: "ClientsOrders",
        snake_name: "track",
        ns_snake_name: "clients_orders",
        segment_params: [],
      ),
    )

  let actual = generate.generate_route_helper(contribution)

  actual
  |> birdie.snap(title: "route_helper")
}

import roundabout/internal/constant
import roundabout/internal/node.{Info, Node, SegLit, SegParam}
import roundabout/internal/parameter
import roundabout/internal/type_name

pub fn fixture_root() {
  Node(Info(type_name.unsafe(""), []), [
    Node(Info(type_name.unsafe("Home"), []), []),
    Node(
      Info(type_name.unsafe("Orders"), [SegLit(constant.unsafe("orders"))]),
      [],
    ),
    Node(
      Info(type_name.unsafe("User"), [
        SegLit(constant.unsafe("users")),
        SegParam(parameter.unsafe_int("user_id")),
      ]),
      [
        Node(Info(type_name.unsafe("Show"), []), []),
        Node(
          Info(type_name.unsafe("Delete"), [SegLit(constant.unsafe("delete"))]),
          [],
        ),
      ],
    ),
  ])
}

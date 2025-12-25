import route_gen/constant
import route_gen/parameter.{type Parameter}

@internal
pub type Segment {
  SegLit(value: constant.Constant)
  SegParam(name: Parameter)
}

@internal
pub type Info {
  Info(name: String, path: List(Segment))
}

@internal
pub type Node {
  Node(info: Info, sub: List(Node))
}

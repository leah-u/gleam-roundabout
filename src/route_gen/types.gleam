@internal
pub type Segment {
  Lit(name: String)
  Str(name: String)
  Int(name: String)
}

@internal
pub type InputDef {
  InputDef(name: String, path: List(Segment), sub: List(InputDef))
}

@internal
pub type Info {
  Info(name: String, segments: List(Segment))
}

@internal
pub type Node {
  Node(children: List(Node), info: Info)
}

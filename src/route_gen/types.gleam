@internal
pub type InputSegment {
  Lit(val: String)
  Str(name: String)
  Int(name: String)
}

@internal
pub type InputDef {
  InputDef(name: String, path: List(InputSegment), sub: List(InputDef))
}

@internal
pub type ParamKind {
  ParamInt
  ParamStr
}

@internal
pub type Param {
  Param(name: String, namespace: String, kind: ParamKind)
}

@internal
pub type ContributionInfo {
  ContributionInfo(
    snake_name: String,
    ns_snake_name: String,
    type_name: String,
    ns_type_name: String,
    segment_params: List(Param),
  )
}

@internal
pub type Contribution {
  Contribution(
    ancestors: List(ContributionInfo),
    children: List(Contribution),
    info: ContributionInfo,
  )
}

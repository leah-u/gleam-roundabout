import birdie
import glam/doc
import roundabout/generate_other

pub fn generate_imports_test() {
  let actual = generate_other.generate_imports()

  actual
  |> doc.to_string(80)
  |> birdie.snap(title: "generate_imports")
}

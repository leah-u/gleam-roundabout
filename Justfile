example-gen:
    cd examples && gleam run -m gen_routes

example-check:
    cd examples && gleam check

snaps:
    gleam run -m birdie

test:
    gleam test

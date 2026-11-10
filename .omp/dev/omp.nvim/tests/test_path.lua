local omp = require("omp")

local function assert_eq(expected, actual, msg)
  if expected ~= actual then
    print(string.format("FAIL: %s | Expected: '%s', Got: '%s'", msg, expected, actual))
    os.exit(1)
  end
end

print("Running OMP tests...")

-- Test: Ignores special buffers
assert_eq("", omp._get_display_path("term://foo", "terminal", 10, 10, "n"), "Should ignore terminal buffers")
assert_eq("", omp._get_display_path("nofile", "nofile", 1, 1, "n"), "Should ignore nofile buffers")

-- Test: Ignores empty buffer names
assert_eq("", omp._get_display_path("", "", 10, 10, "n"), "Should ignore empty buffer names")

-- Test: Formats normal mode correctly
assert_eq(
  "src/main.lua:42",
  omp._get_display_path("src/main.lua", "", 42, 42, "n"),
  "Should format single line in normal mode"
)

-- Test: Formats visual mode ranges
assert_eq(
  "src/main.lua:40-45",
  omp._get_display_path("src/main.lua", "", 45, 40, "v"),
  "Should format visual selection bottom-up"
)
assert_eq(
  "src/main.lua:40-45",
  omp._get_display_path("src/main.lua", "", 40, 45, "v"),
  "Should format visual selection top-down"
)
assert_eq(
  "src/main.lua:40-45",
  omp._get_display_path("src/main.lua", "", 45, 40, "V"),
  "Should format line visual selection"
)

-- Test: a genuine range selection also returns start_line/end_line, so the
-- socket payload can tell a selection apart from a cursor move.
do
  local display_str, start_line, end_line = omp._get_display_path("src/main.lua", "", 45, 40, "v")
  assert_eq("src/main.lua:40-45", display_str, "Range selection display string")
  assert_eq(40, start_line, "Range selection start_line")
  assert_eq(45, end_line, "Range selection end_line")
end

-- Test: cursor movement (no range) returns no start_line/end_line, even in
-- visual mode with the cursor and the start of the selection on one line.
do
  local display_str, start_line, end_line = omp._get_display_path("src/main.lua", "", 42, 42, "v")
  assert_eq("src/main.lua:42", display_str, "Cursor-only display string")
  assert_eq(nil, start_line, "Cursor-only start_line should be nil")
  assert_eq(nil, end_line, "Cursor-only end_line should be nil")
end

print("PASS: All tests passed!")

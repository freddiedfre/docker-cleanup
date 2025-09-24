#!/usr/bin/env bats

setup() {
  SCRIPT="$(pwd)/scripts/docker-cleanup.sh"
}

@test "script exists and is executable" {
  [ -x "$SCRIPT" ]
}

@test "script runs with --help" {
  run "$SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "docker-cleanup: Unified Docker cleanup tool" ]]
}

@test "script runs default cleanup mode" {
  run "$SCRIPT" default
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Default cleanup completed." ]]
}

@test "script can show resources (dry run)" {
  run "$SCRIPT" show
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Docker Resources" ]]
}

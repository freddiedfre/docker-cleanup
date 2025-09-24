#!/usr/bin/env bats

setup() {
  SCRIPT="$(pwd)/scripts/docker-cleanup.sh"

  # Mock docker binary if real docker is unavailable (CI environments)
  if ! command -v docker >/dev/null; then
    mkdir -p "$BATS_TEST_TMPDIR/bin"
    PATH="$BATS_TEST_TMPDIR/bin:$PATH"
    cat >"$BATS_TEST_TMPDIR/bin/docker" <<'EOF'
#!/usr/bin/env bash
# fake docker for CI lint/test
echo "docker $@" >&2
exit 0
EOF
    chmod +x "$BATS_TEST_TMPDIR/bin/docker"
  fi
}

@test "script runs with --help" {
  run "$SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "docker-cleanup: Unified Docker cleanup tool" ]]
}

@test "script runs default cleanup mode" {
  run "$SCRIPT" default
  [ "$status" -eq 0 ]
}

@test "script can show resources (dry run)" {
  run "$SCRIPT" show
  [ "$status" -eq 0 ]
}

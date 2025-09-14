#!/usr/bin/env bats

# Bats is a testing framework for Bash
# Documentation https://bats-core.readthedocs.io/en/stable/
# Bats libraries documentation https://github.com/ztombol/bats-docs

# For local tests, install bats-core, bats-assert, bats-file, bats-support
# And run this in the add-on root directory:
#   bats ./tests/test.bats
# To exclude release tests:
#   bats ./tests/test.bats --filter-tags '!release'
# For debugging:
#   bats ./tests/test.bats --show-output-of-passing-tests --verbose-run --print-output-on-failure

setup() {
  set -eu -o pipefail

  # Override this variable for your add-on:
  export GITHUB_REPO=atj4me/ddev-localtunnel

  TEST_BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  export BATS_LIB_PATH="${BATS_LIB_PATH}:${TEST_BREW_PREFIX}/lib:/usr/lib/bats"
  bats_load_library bats-assert
  bats_load_library bats-file
  bats_load_library bats-support

  export DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." >/dev/null 2>&1 && pwd)"
  export PROJNAME="test-$(basename "${GITHUB_REPO}")"
  mkdir -p ~/tmp
  export TESTDIR=$(mktemp -d ~/tmp/${PROJNAME}.XXXXXX)
  export DDEV_NONINTERACTIVE=true
  export DDEV_NO_INSTRUMENTATION=true
  ddev delete -Oy "${PROJNAME}" >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  run ddev config --project-name="${PROJNAME}" --project-tld=ddev.site
  assert_success
  run ddev start -y
  assert_success
}

health_checks() {
  # Check if the localtunnel service is running inside DDEV
  run ddev describe -j
  assert_success

  # Verify localtunnel service exists in describe output
  run bash -c "ddev describe -j | jq -r '.raw.services | has(\"localtunnel\")'"
  assert_success
  assert_output "true"

  # Check that lt command exists and responds
  run ddev lt status
  assert_success
  
  # Verify the lt command has the expected subcommands
  run ddev lt help
  assert_success
  assert_output --partial "share"
  assert_output --partial "stop"
  assert_output --partial "status"
}

teardown() {
  set -eu -o pipefail
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  # Persist TESTDIR if running inside GitHub Actions. Useful for uploading test result artifacts
  # See example at https://github.com/ddev/github-action-add-on-test#preserving-artifacts
  if [ -n "${GITHUB_ENV:-}" ]; then
    [ -e "${GITHUB_ENV:-}" ] && echo "TESTDIR=${HOME}/tmp/${PROJNAME}" >> "${GITHUB_ENV}"
  else
    [ "${TESTDIR}" != "" ] && rm -rf "${TESTDIR}"
  fi
}

@test "install from directory" {
  set -eu -o pipefail
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}

# bats test_tags=release
@test "install from release" {
  set -eu -o pipefail
  echo "# ddev add-on get ${GITHUB_REPO} with project ${PROJNAME} in $(pwd)" >&3
  run ddev add-on get "${GITHUB_REPO}"
  assert_success
  run ddev restart -y
  assert_success
  health_checks
}

@test "lt command exists and responds" {
  set -eu -o pipefail
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success

  # Test lt command exists
  run ddev lt help
  assert_success
  assert_output --partial "Usage: ddev lt"
  
  # Test status command (should work even without tunnel running)
  run ddev lt status
  assert_success
}

@test "localtunnel service container can be managed" {
  set -eu -o pipefail
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success

  # Check if localtunnel container exists after restart
  run docker ps -a --filter "name=ddev-${PROJNAME}-localtunnel" --format "{{.Names}}"
  assert_success
  assert_output "ddev-${PROJNAME}-localtunnel"
}

@test "configuration files are properly installed" {
  set -eu -o pipefail
  run ddev add-on get "${DIR}"
  assert_success

  # Check if config files exist
  assert_file_exists ".ddev/docker-compose.localtunnel.yaml"
  assert_file_exists ".ddev/commands/host/lt"
  
  # Check if command is executable
  run test -x ".ddev/commands/host/lt"
  assert_success
}

@test "docker-compose file has required services" {
  set -eu -o pipefail
  run ddev add-on get "${DIR}"
  assert_success

  # Check docker-compose file contains required elements
  run grep -q "localtunnel:" ".ddev/docker-compose.localtunnel.yaml"
  assert_success

  run grep -q "image: node:" ".ddev/docker-compose.localtunnel.yaml"
  assert_success
  
  run grep -q "localtunnel" ".ddev/docker-compose.localtunnel.yaml"
  assert_success
}

@test "lt stop command works when no tunnel is running" {
  set -eu -o pipefail
  run ddev add-on get "${DIR}"
  assert_success
  run ddev restart -y
  assert_success

  # Test stop command when nothing is running (should not fail)
  run ddev lt stop
  assert_success
}

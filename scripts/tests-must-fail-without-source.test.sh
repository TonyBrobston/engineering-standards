#!/usr/bin/env bash
set -euo pipefail

script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
script_under_test="${script_directory}/tests-must-fail-without-source.sh"
fixture_root="$(mktemp -d)"
trap 'rm -rf "${fixture_root}"' EXIT

test_command="node --test tests/*.test.mjs"

create_base_repository() {
  local repository="$1"
  mkdir -p "${repository}/src" "${repository}/tests"
  git -C "${repository}" init -q -b main
  git -C "${repository}" config user.email "fixture@example.com"
  git -C "${repository}" config user.name "Fixture"
  cat > "${repository}/src/add.mjs" <<'EOF'
export function add(left, right) {
  return left + right;
}
EOF
  cat > "${repository}/tests/add.test.mjs" <<'EOF'
import assert from "node:assert/strict";
import { test } from "node:test";
import { add } from "../src/add.mjs";

test("adds two numbers", () => {
  assert.equal(add(2, 3), 5);
});
EOF
  git -C "${repository}" add -A
  git -C "${repository}" commit -qm "base"
  git -C "${repository}" checkout -qb feature
}

run_script() {
  local repository="$1"
  (cd "${repository}" && bash "${script_under_test}" main "${test_command}" '^src/' >/dev/null 2>&1)
}

expect_exit() {
  local expected="$1" actual="$2" scenario="$3"
  if [[ "${expected}" == "${actual}" ]]; then
    echo "ok - ${scenario}"
  else
    echo "not ok - ${scenario} (expected exit ${expected}, got ${actual})"
    exit 1
  fi
}

scenario_feature_with_real_test() {
  local repository="${fixture_root}/feature-with-real-test"
  create_base_repository "${repository}"
  cat > "${repository}/src/multiply.mjs" <<'EOF'
export function multiply(left, right) {
  return left * right;
}
EOF
  cat > "${repository}/tests/multiply.test.mjs" <<'EOF'
import assert from "node:assert/strict";
import { test } from "node:test";
import { multiply } from "../src/multiply.mjs";

test("multiplies two numbers", () => {
  assert.equal(multiply(2, 3), 6);
});
EOF
  git -C "${repository}" add -A && git -C "${repository}" commit -qm "multiply"
  set +e; run_script "${repository}"; local code=$?; set -e
  expect_exit 0 "${code}" "feature with a test that depends on it passes"
  [[ -f "${repository}/src/multiply.mjs" ]] || { echo "not ok - working tree not restored"; exit 1; }
}

scenario_source_without_test() {
  local repository="${fixture_root}/source-without-test"
  create_base_repository "${repository}"
  cat > "${repository}/src/add.mjs" <<'EOF'
export function add(left, right) {
  return Number(left) + Number(right);
}
EOF
  git -C "${repository}" add -A && git -C "${repository}" commit -qm "coerce"
  set +e; run_script "${repository}"; local code=$?; set -e
  expect_exit 1 "${code}" "source change without a test change fails"
}

scenario_test_independent_of_change() {
  local repository="${fixture_root}/test-independent"
  create_base_repository "${repository}"
  cat > "${repository}/src/add.mjs" <<'EOF'
export function add(left, right) {
  return Number(left) + Number(right);
}
EOF
  cat > "${repository}/tests/add.test.mjs" <<'EOF'
import assert from "node:assert/strict";
import { test } from "node:test";
import { add } from "../src/add.mjs";

test("adds two numbers", () => {
  assert.equal(add(2, 3), 5);
});

test("adds zero", () => {
  assert.equal(add(0, 0), 0);
});
EOF
  git -C "${repository}" add -A && git -C "${repository}" commit -qm "coerce with unrelated test"
  set +e; run_script "${repository}"; local code=$?; set -e
  expect_exit 1 "${code}" "a test that passes without the change fails the proof"
}

scenario_test_only_change() {
  local repository="${fixture_root}/test-only"
  create_base_repository "${repository}"
  cat >> "${repository}/tests/add.test.mjs" <<'EOF'

test("adds negatives", () => {
  assert.equal(add(-2, -3), -5);
});
EOF
  git -C "${repository}" add -A && git -C "${repository}" commit -qm "more tests"
  set +e; run_script "${repository}"; local code=$?; set -e
  expect_exit 0 "${code}" "a test-only change has nothing to prove"
}

scenario_feature_with_real_test
scenario_source_without_test
scenario_test_independent_of_change
scenario_test_only_change
echo "tests-must-fail-without-source: all scenarios passed"

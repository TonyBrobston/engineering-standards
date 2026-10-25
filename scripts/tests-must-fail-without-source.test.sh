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

expect_clean_repository() {
  local repository="$1"
  if [[ -n "$(git -C "${repository}" status --porcelain)" ]]; then
    echo "not ok - working tree or index not restored"
    git -C "${repository}" status --short
    exit 1
  fi
}

scenario_nested_project() {
  local scenario="$1" expected="$2"
  local repository="${fixture_root}/nested-${scenario}"
  create_base_repository "${repository}"
  mkdir "${repository}/ui"
  git -C "${repository}" mv src tests ui/
  git -C "${repository}" commit -qm "nest project"
  git -C "${repository}" branch -f main HEAD
  sed -i 's/left + right/Number(left) + Number(right)/' "${repository}/ui/src/add.mjs"
  if [[ "${scenario}" == real-test ]]; then
    cat >> "${repository}/ui/tests/add.test.mjs" <<'EOF'

test("coerces strings", () => {
  assert.equal(add("2", "3"), 5);
});
EOF
  elif [[ "${scenario}" == unrelated-test ]]; then
    cat >> "${repository}/ui/tests/add.test.mjs" <<'EOF'

test("adds zero", () => {
  assert.equal(add(0, 0), 0);
});
EOF
  elif [[ "${scenario}" == sibling-test ]]; then
    mkdir "${repository}/tests"
    echo 'export const total = 1;' > "${repository}/tests/sibling.test.mjs"
  fi
  git -C "${repository}" add -A
  git -C "${repository}" commit -qm "nested change"
  set +e; run_script "${repository}/ui"; local code=$?; set -e
  expect_exit "${expected}" "${code}" "nested project ${scenario}"
  expect_clean_repository "${repository}"
}

scenario_deleted_source() {
  local scenario="$1" expected="$2" nested="${3:-}"
  local repository="${fixture_root}/deleted-${scenario}-${nested:-root}"
  create_base_repository "${repository}"
  if [[ -n "${nested}" ]]; then
    mkdir "${repository}/${nested}"
    git -C "${repository}" mv src tests "${nested}/"
    git -C "${repository}" commit -qm "nest project"
    git -C "${repository}" branch -f main HEAD
  fi
  local project="${repository}${nested:+/${nested}}"
  git -C "${project}" rm -q src/add.mjs
  if [[ "${scenario}" == real-test ]]; then
    cat > "${project}/tests/add.test.mjs" <<'EOF'
import assert from "node:assert/strict";
import { existsSync } from "node:fs";
import { test } from "node:test";

test("obsolete implementation is absent", () => {
  assert.equal(existsSync("src/add.mjs"), false);
});
EOF
  elif [[ "${scenario}" == unrelated-test ]]; then
    echo 'import { test } from "node:test"; test("unrelated", () => {});' > "${project}/tests/add.test.mjs"
  fi
  git -C "${repository}" add -A
  git -C "${repository}" commit -qm "delete implementation"
  set +e; run_script "${project}"; local code=$?; set -e
  expect_exit "${expected}" "${code}" "deleted source ${scenario} ${nested}"
  [[ ! -e "${project}/src/add.mjs" ]] || { echo "not ok - deletion not restored"; exit 1; }
  expect_clean_repository "${repository}"
}

scenario_nested_project real-test 0
scenario_nested_project unrelated-test 1
scenario_nested_project without-test 1
scenario_nested_project sibling-test 1
scenario_deleted_source real-test 0
scenario_deleted_source unrelated-test 1
scenario_deleted_source without-test 1
scenario_deleted_source real-test 0 ui
scenario_deleted_source unrelated-test 1 ui

scenario_feature_with_real_test
scenario_source_without_test
scenario_test_independent_of_change
scenario_test_only_change
echo "tests-must-fail-without-source: all scenarios passed"

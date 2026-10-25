#!/usr/bin/env bash
set -euo pipefail

base_ref="${1:?usage: tests-must-fail-without-source.sh <base-ref> <test-command> [source-pattern] [test-pattern]}"
test_command="${2:?usage: tests-must-fail-without-source.sh <base-ref> <test-command> [source-pattern] [test-pattern]}"
source_pattern="${3:-^(src|lib|firmware/lib|custom_components)/}"
test_pattern="${4:-(^|/)(tests?|__tests__|spec)/|\.(test|spec)\.[a-z]+$|(^|/)test_[^/]+\.py$}"

changed_files="$(git diff --name-only --diff-filter=ACMR "${base_ref}...HEAD")"
changed_test_files="$(printf '%s\n' "${changed_files}" | grep -E "${test_pattern}" || true)"
changed_source_files="$(printf '%s\n' "${changed_files}" | grep -E "${source_pattern}" | grep -vE "${test_pattern}" || true)"

if [[ -z "${changed_source_files}" ]]; then
  echo "No source files changed; nothing to prove."
  exit 0
fi

if [[ -z "${changed_test_files}" ]]; then
  echo "::error::Source changed without a test change. Write the failing test first, or label the PR 'refactor'."
  printf 'Changed source files:\n%s\n' "${changed_source_files}"
  exit 1
fi

echo "Reverting changed source files to ${base_ref} and keeping the PR's tests:"
printf '%s\n' "${changed_source_files}"

while IFS= read -r source_file; do
  if git cat-file -e "${base_ref}:${source_file}" 2>/dev/null; then
    git checkout "${base_ref}" -- "${source_file}"
  else
    rm -f "${source_file}"
  fi
done <<< "${changed_source_files}"

set +e
bash -c "${test_command}"
test_exit_code=$?
set -e

git checkout HEAD -- .

if [[ "${test_exit_code}" -eq 0 ]]; then
  echo "::error::The PR's tests pass against the base branch's source, so they do not test this change. Write a test that fails without the implementation."
  exit 1
fi

echo "Tests fail without the implementation (exit ${test_exit_code}). Test-first proof passed."

#!/usr/bin/env bash
set -euo pipefail

base_ref="${1:?usage: tests-must-fail-without-source.sh <base-ref> <test-command> [source-pattern] [test-pattern]}"
test_command="${2:?usage: tests-must-fail-without-source.sh <base-ref> <test-command> [source-pattern] [test-pattern]}"
source_pattern="${3:-^(src|lib|firmware/lib|custom_components)/}"
test_pattern="${4:-(^|/)(tests?|__tests__|spec)/|\.(test|spec)\.[a-z]+$|(^|/)test_[^/]+\.py$}"

repository_prefix="$(git rev-parse --show-prefix)"
changed_source_files=()
changed_test_files=()

changed_file_list="$(mktemp)"
trap 'rm -f -- "${changed_file_list}"' EXIT
git diff --relative --name-only -z --no-renames --diff-filter=ACDMRT "${base_ref}...HEAD" -- . > "${changed_file_list}"

while IFS= read -r -d '' changed_file; do
  if [[ "${changed_file}" =~ ${test_pattern} ]]; then
    changed_test_files+=("${changed_file}")
  elif [[ "${changed_file}" =~ ${source_pattern} ]]; then
    changed_source_files+=("${changed_file}")
  fi
done < "${changed_file_list}"
rm -f -- "${changed_file_list}"
trap - EXIT

if [[ "${#changed_source_files[@]}" -eq 0 ]]; then
  echo "No source files changed; nothing to prove."
  exit 0
fi

if [[ "${#changed_test_files[@]}" -eq 0 ]]; then
  echo "::error::Source changed without a test change. Write the failing test first, or label the PR 'refactor'."
  printf 'Changed source file: %s\n' "${changed_source_files[@]}"
  exit 1
fi

echo "Reverting changed source files to ${base_ref} and keeping the PR's tests:"
printf '%s\n' "${changed_source_files[@]}"

restore_source() {
  git restore --source=HEAD --staged --worktree -- "${changed_source_files[@]}"
}
trap restore_source EXIT

for source_file in "${changed_source_files[@]}"; do
  if git cat-file -e "${base_ref}:${repository_prefix}${source_file}" 2>/dev/null; then
    git restore --source="${base_ref}" --staged --worktree -- "${source_file}"
  else
    rm -f -- "${source_file}"
  fi
done

set +e
bash -c "${test_command}"
test_exit_code=$?
set -e

if [[ "${test_exit_code}" -eq 0 ]]; then
  echo "::error::The PR's tests pass against the base branch's source, so they do not test this change. Write a test that fails without the implementation."
  exit 1
fi

echo "Tests fail without the implementation (exit ${test_exit_code}). Test-first proof passed."

#!/usr/bin/env bash

if [ "$1" = "staging-test" ]; then
  echo "non-porcelain output 1"
  echo "ansible-vaulted[to-add]:/foo/bar.txt.vault"
  echo "non-porcelain output 2"
  echo "ansible-vaulted[to-add]:/baz/bar/foo:bar.vault"
  echo "non-porcelain output 3"
  exit 0
fi

SELF_DIR="$(cd "$(dirname "$0")" && pwd)"
SUT_DIR="$(dirname "${SELF_DIR}")"
SELF_SCRIPT="$(basename "$0")"
export OVERRIDE_CORE_SCRIPT="${SELF_DIR}/${SELF_SCRIPT} staging-test"
export OVERRIDE_STAGE_COMMAND="/bin/echo testgit add"

hook_output=$(mktemp)
"${SUT_DIR}"/hook.sh | tee "${hook_output}"

echo "🔸diff{"
echo \
  "non-porcelain output 1
testgit add /foo/bar.txt.vault
non-porcelain output 2
testgit add /baz/bar/foo:bar.vault
non-porcelain output 3" | diff -u "${hook_output}" -
DIFF_RC=$?
rm -f "${hook_output}"
echo "}diff🔸"

if [ ! 0 -eq ${DIFF_RC} ]; then
  echo "❌ FAILED"
  exit 1
else
  echo "✅ PASSED"
fi

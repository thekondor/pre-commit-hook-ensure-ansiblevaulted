#!/usr/bin/env bash

SELF_DIR="$(cd "$(dirname "$0")" && pwd)"
SUT_DIR="$(dirname "${SELF_DIR}")"

if ! test_repo=$(mktemp -d); then
  echo "mktemp: failed"
  exit 1
fi

cleanup() {
  deactivate >/dev/null 2>&1
  if [ -n "${test_repo}" ]; then
    rm -rf "${test_repo}"
  fi

  if ! popd; then
    echo "returning back fro the test repo dir failed"
    exit 1
  fi
}
trap cleanup EXIT

if [ -z "${test_repo}" ]; then
  echo "invalid repo root"
  exit 1
fi

if ! pushd "${test_repo}"; then
  echo "switching to test repo '${test_repo}' failed"
  exit 1
fi

if ! git init .; then
  echo "git repo initialization failed"
  exit 1
fi

if [ -z "${USE_SYSTEM_ANSIBLE}" ]; then
  if ! virtualenv venv; then
    echo "failed: establish virtualenv"
    exit 1
  fi
  # shellcheck disable=SC1091
  source venv/bin/activate

  if ! pip install ansible-vault; then
    echo "failed: install ansible-vault"
    exit 1
  fi
fi

cp -r "${SELF_DIR}"/payload/core-smoke.test-repo.d/. .
cp -r "${SELF_DIR}"/payload/core-smoke.cfg.d/. .
ls -la .

### This will also add `.vault-password` which in normal case doesn't belong there
git add .
git commit -m "initial commit"

"${SUT_DIR}"/hook.sh

git_staged_output=$(mktemp)
git diff --name-only --cached | tee "${git_staged_output}" | while read -r staged; do
  # shellcheck disable=SC2016
  if ! head -n 1 "${staged}" | grep '\$ANSIBLE_VAULT' >/dev/null 2>&1; then
    echo "❌❗️ Malformed vault"
    exit 1
  fi
done

echo "🔸diff{"
echo \
  "dirA1/dirA2/repo.another-secret.vault
dirA1/repo.new-secret.vault
repo.secret.vault" | diff -u "${git_staged_output}" -
DIFF_RC=$?
rm -f "${git_staged_output}"
echo "}diff🔸"

if [ ! 0 -eq ${DIFF_RC} ]; then
  echo "❌ FAILED"
  exit 1
else
  echo "✅ PASSED"
fi

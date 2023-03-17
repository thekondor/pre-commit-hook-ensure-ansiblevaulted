#!/usr/bin/env bash
# -*- coding: utf-8 -*-

#
# (c) 2023, Andrew Sichevoi https://thekondor.net
#

SELF_DIR="$(cd "$(dirname "$0")" && pwd)"
SUT_DIR="$(dirname "${SELF_DIR}")"

# shellcheck source=tests/common_test-repo.sh.inc
source "${SELF_DIR}/common_test-repo.sh.inc"

create_test_repo

cp -r "${SELF_DIR}"/payload/core-smoke.test-repo.d/. .

if error_msg="$("${SUT_DIR}"/hook.sh 2>&1)"; then
  echo "- non-zero exit is expected, output:"
  echo "  '${error_msg}'"
  echo "❌ FAILED"
  exit 1
fi

if ! echo "${error_msg}" | grep -q "configuration file.*is mandatory"; then
  echo "- Unexpected error message, output:"
  echo "  '${error_msg}'"
  echo "❌ FAILED"
  exit 1
fi

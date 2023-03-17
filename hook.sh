#!/usr/bin/env bash
# -*- coding: utf-8 -*-

#
# (c) 2023, Andrew Sichevoi https://thekondor.net
#

readonly DEBUG=${DEBUG:-unset}
if [ "${DEBUG}" != unset ]; then
  set -x
fi

SELF_DIR="$(cd "$(dirname "$0")" && pwd)"
PORCELAIN_PATTERN="ansible-vaulted\[to-add\]"

CORE_SCRIPT="${SELF_DIR}/ensure-ansible-vaulted.sh"
if [ -n "${OVERRIDE_CORE_SCRIPT}" ]; then
  CORE_SCRIPT="${OVERRIDE_CORE_SCRIPT}"
fi

STAGE_COMMAND="git add"
if [ -n "${OVERRIDE_STAGE_COMMAND}" ]; then
  STAGE_COMMAND="${OVERRIDE_STAGE_COMMAND}"
fi

if ! core_script_output="$(${CORE_SCRIPT})"; then
  echo "❌ core script failed: ${core_script_output}"
  exit 1
fi

while read -r OUTPUT; do
  if ! echo "${OUTPUT}" | grep "${PORCELAIN_PATTERN}" >/dev/null 2>&1; then
    echo "$OUTPUT"
    continue
  fi

  encrypted_full_path=$(echo "${OUTPUT}" | cut -d : -f 2-)
  if ! ${STAGE_COMMAND} "${encrypted_full_path}"; then
    echo "❌ staging failed"
    exit 1
  fi
done <<<"${core_script_output}"

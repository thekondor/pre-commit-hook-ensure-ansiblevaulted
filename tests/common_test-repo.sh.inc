# shellcheck disable=SC2148
# -*- coding: utf-8 -*-

#
# (c) 2023, Andrew Sichevoi https://thekondor.net
#

TEST_REPO=""
PUSHD_TO_TEST_REPO_ON_CREATE=true
create_test_repo() {
	if ! test_repo=$(mktemp -d); then
		echo "mktemp: failed"
		exit 1
	fi

	if [ -z "${test_repo}" ]; then
		echo "invalid repo root"
		exit 1
	fi

	if [ ${PUSHD_TO_TEST_REPO_ON_CREATE} ]; then
		if ! pushd "${test_repo}"; then
			echo "switching to test repo '${test_repo}' failed"
			exit 1
		fi
	fi

	TEST_REPO="${test_repo}"
}

POPD_FROM_TEST_REPO_ON_CLEANUP=true
test_repo_cleanup() {
	deactivate >/dev/null 2>&1
	if [ -n "${test_repo}" ]; then
		rm -rf "${test_repo}"
	fi

	if [ ${POPD_FROM_TEST_REPO_ON_CLEANUP} ]; then
		if ! popd; then
			echo "returning back fro the test repo dir failed"
			exit 1
		fi
	fi
}
trap test_repo_cleanup EXIT

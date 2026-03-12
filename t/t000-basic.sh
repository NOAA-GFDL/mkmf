#!/usr/bin/env bats

setup() {
   # During conda build/test, $PREFIX points to the just-installed package.
   if [[ -n "${PREFIX:-}" && -x "${PREFIX}/bin/mkmf" ]]; then
      export PATH="${PREFIX}/bin:${PATH}"
   fi

   # Fail immediately if mkmf is not on PATH — don't silently fall back.
   if ! command -v mkmf >/dev/null 2>&1; then
      echo "ERROR: mkmf not found on PATH." >&2
      echo "If testing locally, add the repo bin directory first:" >&2
      echo "  export PATH=\"\$(readlink -f mkmf/bin):\$PATH\"" >&2
      return 1
   fi

   # Temporary directory where tests are run
   testDir=$(mktemp -d ${BATS_TEST_DIRNAME}/${BATS_TEST_NAME}.XXXXXXXX)
   cd ${testDir}
}

teardown() {
   rm -rf ${testDir}
}

@test "mkmf is in path" {
   run hash mkmf
   [ "$status" -eq 0 ]
}

@test "mkmf can be run" {
   run mkmf
   [ "$status" -eq 0 ]
   [ -e ${testDir}/Makefile ]
}

@test "list_paths is in path" {
   run hash list_paths
   [ "$status" -eq 0 ]
}

@test "list_paths can be run" {
   run list_paths -h
   [ "$status" -eq 0 ]
}

@test "git-version-string is in path" {
   run hash git-version-string
   [ "$status" -eq 0 ]
}

@test "git-version-string can be run" {
   run git-version-string
   [ "$status" -eq 1 ]
}

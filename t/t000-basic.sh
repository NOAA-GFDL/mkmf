#!/usr/bin/env bats

setup() {
   # Always prepend the correct bin directory to PATH so we test the intended
   # copy of mkmf — never an unrelated one that happens to be on the user's
   # PATH already (which would hide failures, as underwoo noted in review).
   #
   # During "conda build" testing, $PREFIX points to the environment where
   # the just-built package was installed; we test those installed binaries.
   # In local development we use the repo's own mkmf/bin/ directory.
   if [[ -n "${PREFIX:-}" && -x "${PREFIX}/bin/mkmf" ]]; then
      binDir="${PREFIX}/bin"
   else
      binDir=$(readlink -f "${BATS_TEST_DIRNAME}/../mkmf/bin")
   fi
   export PATH="${binDir}:${PATH}"

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

#!/usr/bin/env bats

setup() {
   binDir=$(readlink -f ${BATS_TEST_DIRNAME}/../bin)
   testDir=$(mktemp -d ${BATS_TEST_DIRNAME}/${BATS_TEST_NAME}.XXXXXXXX)
   export PATH=${binDir}:${PATH}
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

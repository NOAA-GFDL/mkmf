#!/usr/bin/env bats

setup() {
   # Determine where the mkmf binaries are.
   # When mkmf is conda-installed it is already on PATH and that installed
   # copy is the one under test.  When developing locally without a conda
   # install, prepend the repo's bin/ dir so the tests exercise the local
   # working copy instead of any system copy.
   binDir=$(readlink -f ${BATS_TEST_DIRNAME}/../mkmf/bin)
   if [ $(command -v mkmf) ]; then
      echo "mkmf found in PATH (conda install); using that copy for tests."
   else
      export PATH=${binDir}:${PATH}
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

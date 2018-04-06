#!/usr/bin/env bats

setup() {
   # Set the PATH
   binDir=$(readlink -f ${BATS_TEST_DIRNAME}/../bin)
   export PATH=${binDir}:${PATH}
   # Temporary directory where tests are run
   testDir=$(mktemp -d ${BATS_TEST_DIRNAME}/${BATS_TEST_NAME}.XXXXXXXX)
   cd ${testDir}
}

teardown() {
   rm -rf ${testDir}
}

@test "list_paths prints version" {
   run list_paths -V
   echo $output
   [ "$status" -eq 0 ]
   [[ "$output" =~ ^list_paths\ [0-9]+\.[0-9]+$ ]]
}

@test "list_paths requires at least one argument" {
   run list_paths
   [ "$status" -eq 1 ]
}

@test "list_paths using default out file" {
   run list_paths ${BATS_TEST_DIRNAME}/src
   [ -e path_names ]
   [ "$(wc -l < path_names)" -eq 6 ]
}

@test "list_paths verbose output" {
   run list_paths -v ${BATS_TEST_DIRNAME}/src
   [ "$status" -eq 0 ]
}

@test "list_paths with specified out file" {
   outFileName=$(mktemp -u output.XXXXXXXX)
   run list_paths -o ${outFileName} ${BATS_TEST_DIRNAME}/src
   [ -e ${outFileName} ]
   [ "$(wc -l < $outFileName)" -eq 6 ]
}

@test "list_paths finds html files" {
   run list_paths -d ${BATS_TEST_DIRNAME}/src
   [ -e path_names ]
   [ -e path_names.html ]
   [ "$(wc -l < path_names.html)" -eq 5 ]
}

@test "list_paths find symlinks" {
   run list_paths -l ${BATS_TEST_DIRNAME}/src
   [ -e path_names ]
   [ "$(wc -l < path_names)" -eq 7 ]
}

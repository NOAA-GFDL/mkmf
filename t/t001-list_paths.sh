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

   # Create an isolated temporary directory and populate it with a copy of
   # t/src/.  The symlink file6.f90 -> file6.linked is created here rather
   # than inside the real source tree so that teardown cleans everything up
   # automatically and a killed/failed test never leaves a stale symlink.
   testDir=$(mktemp -d ${BATS_TEST_DIRNAME}/${BATS_TEST_NAME}.XXXXXXXX)
   cp -r ${BATS_TEST_DIRNAME}/src ${testDir}/src
   ln -s file6.linked ${testDir}/src/file6.f90

   cd ${testDir}
}

teardown() {
   # testDir contains the src copy and symlink — no separate file removal needed.
   rm -rf ${testDir}
}

# Return the number of lines in a file.
# Usage: count_lines <file>
count_lines() {
   wc -l < "$1"
}

@test "list_paths prints version" {
   run list_paths -V
   [ "$status" -eq 0 ]
   [[ "$output" =~ ^list_paths\ [0-9]+\.[0-9]+\.[0-9]+$ ]]
   echo $output
}

@test "list_paths requires at least one argument" {
   run list_paths
   [ "$status" -eq 1 ]
}

@test "list_paths using default out file" {
   run list_paths ${testDir}/src
   [ "$status" -eq 0 ]
   [ -e path_names ]
   num_paths=$(count_lines path_names)
   echo $num_paths
   cat path_names
   [ $num_paths -eq 6 ]
}

@test "list_paths verbose output" {
   run list_paths -v ${testDir}/src
   [ "$status" -eq 0 ]
   [ -e path_names ]
   num_paths=$(count_lines path_names)
   echo $num_paths
   cat path_names
   [ $num_paths -eq 6 ]
}

@test "list_paths find files in t and test_* directories" {
   run list_paths -t ${testDir}/src
   [ "$status" -eq 0 ]
   [ -e path_names ]
   num_paths=$(count_lines path_names)
   echo $num_paths
   cat path_names
   [ $num_paths -eq 8 ]
}

@test "list_paths find specific files in t or test_* directories" {
   run list_paths ${testDir}/src ${testDir}/src/t/file7.F90
   [ "$status" -eq 0 ]
   [ -e path_names ]
   num_paths=$(count_lines path_names)
   echo $num_paths
   cat path_names
   [ $num_paths -eq 7 ]
}

@test "list_paths with specified out file" {
   outFileName=$(mktemp -u output.XXXXXXXX)
   run list_paths -o ${outFileName} ${testDir}/src
   [ "$status" -eq 0 ]
   [ -e ${outFileName} ]
   num_paths=$(count_lines $outFileName)
   echo $num_paths
   cat $outFileName
   [ $num_paths -eq 6 ]
}

@test "list_paths finds html files" {
   run list_paths -d ${testDir}/src
   [ "$status" -eq 0 ]
   [ -e path_names ]
   [ -e path_names.html ]
   num_paths=$(count_lines path_names)
   echo $num_paths
   cat path_names
   [ $num_paths -eq 6 ]
}

@test "list_paths find symlinks" {
   run list_paths -l ${testDir}/src
   [ "$status" -eq 0 ]
   [ -e path_names ]
   num_paths=$(count_lines path_names)
   echo $num_paths
   cat path_names
   [ $num_paths -eq 7 ]
}

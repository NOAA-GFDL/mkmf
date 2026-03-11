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

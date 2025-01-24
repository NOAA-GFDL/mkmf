#!/usr/bin/env bats

setup() {
   # set PATH if needed
   binDir=$(readlink -f ${BATS_TEST_DIRNAME}/../mkmf/bin)
   which mkmf
   if [ $? -eq 0 ]; then
	   echo 'likely conda case'
   else
	   export PATH=${binDir}:${PATH}
   fi
   
   # for tests/cases that depend on a symbolic link to cover
   cd ${BATS_TEST_DIRNAME}/src \
	   && ln -s file6.linked file6.f90
   cd -
   
   # Temporary directory where tests are run
   testDir=$(mktemp -d ${BATS_TEST_DIRNAME}/${BATS_TEST_NAME}.XXXXXXXX)
   cd ${testDir}
}

teardown() {
   rm -f ${BATS_TEST_DIRNAME}/src/file6.f90
   rm -rf ${testDir}
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
   run list_paths ${BATS_TEST_DIRNAME}/src
   [ "$status" -eq 0 ]
   [ -e path_names ]
   num_paths=$(cat path_names | wc -l)
   echo $num_paths
   cat path_names
   [ $num_paths -eq 6 ] #local answer
#   [ $num_paths -eq 7 ] #current conda build test answer
}

@test "list_paths verbose output" {
   run list_paths -v ${BATS_TEST_DIRNAME}/src
   [ "$status" -eq 0 ]
   [ -e path_names ]
   num_paths=$(cat path_names | wc -l)
   echo $num_paths
   cat path_names   
   [ $num_paths -eq 6 ] #local answer
#   [ $num_paths -eq 7 ] #current conda build test answer
}

@test "list_paths find files in t and test_* directories" {
   run list_paths -t ${BATS_TEST_DIRNAME}/src
   [ "$status" -eq 0 ]
   [ -e path_names ]
   num_paths=$(cat path_names | wc -l)
   echo $num_paths
   cat path_names
   [ $num_paths -eq 8 ] #local answer
#   [ $num_paths -eq 9 ] #current conda build test answer
}

@test "list_paths find specific files in t or test_* directories" {
   run list_paths ${BATS_TEST_DIRNAME}/src ${BATS_TEST_DIRNAME}/src/t/file7.F90
   [ "$status" -eq 0 ]
   [ -e path_names ]
   num_paths=$(cat path_names | wc -l)
   echo $num_paths
   cat path_names
   [ $num_paths -eq 7 ] #local answer
#   [ $num_paths -eq 8 ] #current conda build test answer
}

@test "list_paths with specified out file" {
   outFileName=$(mktemp -u output.XXXXXXXX)
   run list_paths -o ${outFileName} ${BATS_TEST_DIRNAME}/src
   [ "$status" -eq 0 ]
   [ -e ${outFileName} ]
   num_paths=$(cat $outFileName | wc -l)
   echo $num_paths
   cat $outFileName
   [ $num_paths -eq 6 ] #local answer
#   [ $num_paths -eq 7 ] #current conda build test answer
}

@test "list_paths finds html files" {
   run list_paths -d ${BATS_TEST_DIRNAME}/src
   [ "$status" -eq 0 ]
   [ -e path_names ]
   [ -e path_names.html ]
   num_paths=$(cat path_names | wc -l)
   echo $num_paths
   cat path_names
   [ $num_paths -eq 6 ] #local answer
#   [ $num_paths -eq 7 ] #current conda build test answer
}

@test "list_paths find symlinks" {
   run list_paths -l ${BATS_TEST_DIRNAME}/src
   [ "$status" -eq 0 ]
   [ -e path_names ]
   num_paths=$(cat path_names | wc -l)
   echo $num_paths
   cat path_names
   [ $num_paths -eq 7 ]
}

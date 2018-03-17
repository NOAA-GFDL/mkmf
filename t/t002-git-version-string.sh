#!/usr/bin/env bats

setup() {
   # Set the PATH
   binDir=$(readlink -f ${BATS_TEST_DIRNAME}/../bin)
   export PATH=${binDir}:${PATH}
   # Temporary directory where tests are run
   testDir=$(mktemp -d ${BATS_TEST_DIRNAME}/${BATS_TEST_NAME}.XXXXXXXX)
   cd ${testDir}
   # Setup the git repository with files with random strings
   git init .
   tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1 > file1
   git add .
   git commit -m 'Temporary git repo for testing'
}

teardown() {
   rm -rf ${testDir}
}

@test "git-version-string returns hash for committed file" {
   repoHash=$(git rev-parse HEAD)
   run git-version-string file1
   [ "$status" -eq 0 ]
   [ "$output" = "'ref:${repoHash}'" ]
}

@test "git-version-string has for untracked file" {
   tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1 > file2
   repoHash=$(git rev-parse HEAD)
   fileHash=$(git hash-object file2)
   run git-version-string file2
   [ "$status" -eq 0 ]
   [ "$output" = "'ref:${repoHash} status:Untracked blob:${fileHash}'" ]
}

@test "git-version-string file outside repository" {
   fileHash=$(git hash-object /dev/null)
   run git-version-string /dev/null
   [ "$status" -eq 0 ]
   [ "$(echo $output)" = "'status:UNKNOWN blob:${fileHash}' WARNING: Not in a git repository" ]
}

@test "git-version-string modified file" {
   echo "New line" >> file1
   repoHash=$(git rev-parse HEAD)
   fileHash=$(git hash-object file1)
   run git-version-string file1
   [ "$status" -eq 0 ]
   [ "$output" = "'ref:${repoHash} status:Modified blob:${fileHash}'" ]
}

@test "git-version-string added file" {
   tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1 > file2
   git add .
   repoHash=$(git rev-parse HEAD)
   fileHash=$(git hash-object file2)
   run git-version-string file2
   [ "$status" -eq 0 ]
   [ "$output" = "'ref:${repoHash} status:Added blob:${fileHash}'" ]
}   

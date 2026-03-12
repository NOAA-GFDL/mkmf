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

   # Setup the git repository with files with random strings
   git init .
   tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1 > file1
   [ -e file1 ]
   cat file1
   git add ./file1
   git config --local user.email "you@example.com"
   git config --local user.name "Your Name"
   git commit -o file1 -m 'Temporary git repo for testing- file1 filled with stuff'
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

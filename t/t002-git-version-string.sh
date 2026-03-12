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

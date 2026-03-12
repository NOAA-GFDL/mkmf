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

   # test template file
   mkmf_test_template="${BATS_TEST_DIRNAME}/templates/test_gnu.mk"

   cd ${testDir}
}

teardown() {
   # testDir contains the src copy and symlink — no separate file removal needed.
   rm -rf ${testDir}
}

@test "mkmf verbose option" {
   run mkmf -v
   [ "$status" -eq 0 ]
   [ -e Makefile ]
}

@test "mkmf debug option" {
   run mkmf -d
   [ "$status" -eq 0 ]
   [ -e Makefile ]
}

@test "mkmf accepts -p program" {
   run mkmf -p test_program
   [ "$status" -eq 0 ]
   [ -e Makefile ]
   run grep -q '^all: test_program$' Makefile
   [ "$status" -eq 0 ]
   run grep -q '^test_program: \$(OBJ)$' Makefile
   [ "$status" -eq 0 ]
   run grep -q '\$(LD) \$(OBJ) -o test_program  $(LDFLAGS)$' Makefile
   [ "$status" -eq 0 ]
}

@test "mkmf accepts -p library.a" {
   run mkmf -p libtest.a
   [ "$status" -eq 0 ]
   [ -e Makefile ]
   run grep -q '^all: libtest.a$' Makefile
   [ "$status" -eq 0 ]
   run grep -q '^libtest.a: \$(OBJ)$' Makefile
   [ "$status" -eq 0 ]
   run grep -q '\$(AR) \$(ARFLAGS) libtest.a $(OBJ)$' Makefile
   [ "$status" -eq 0 ]
}

@test "mkmf accepts CPPDEFS" {
   run mkmf -c "-DSOMEDEFS"
   [ "$status" -eq 0 ]
   [ -e Makefile ]
   [ -e .a.out.cppdefs ]
   run grep -q '^CPPDEFS = -DSOMEDEFS$' Makefile
   [ "$status" -eq 0 ]
   run grep -q '^ SOMEDEFS$' .a.out.cppdefs
   [ "$status" -eq 0 ]
}

@test "mkmf .a.out.cppdefs ignores non-cppdef/undef options in -c" {
   run mkmf -c "-DSOMEDEFS -other"
   [ "$status" -eq 0 ]
   [ -e Makefile ]
   [ -e .a.out.cppdefs ]
   run grep -q '^CPPDEFS = -DSOMEDEFS -other$' Makefile
   [ "$status" -eq 0 ]
   run grep -q '^ SOMEDEFS$' .a.out.cppdefs
   [ "$status" -eq 0 ]
}

@test "mkmf include make template file with -t" {
   run mkmf -t ${mkmf_test_template}
   [ "$status" -eq 0 ]
   [ -e Makefile ]
   regexString="^MK_TEMPLATE = ${mkmf_test_template}\$"
   run grep -q "$regexString" Makefile
   [ "$status" -eq 0 ]
   run grep -q '^include $(MK_TEMPLATE)$' Makefile
   [ "$status" -eq 0 ]
}

@test "mkmf finds sources in directory" {
   run mkmf ${testDir}/src
   [ "$status" -eq 0 ]
   [ -e Makefile ]
   regexString="^\./file4\.c: ${testDir}/src/file4\.c$"
   run grep -q "${regexString}" Makefile
   [ "$status" -eq 0 ]
}

@test "mkmf use srcdir in Makefile" {
   run mkmf -a ${testDir}/src ${testDir}/src
   [ "$status" -eq 0 ]
   [ -e Makefile ]
   regexString='^\./file3\.f: \$(SRCROOT)\./file3.f$'
   run grep -q "${regexString}" Makefile
   [ "$status" -eq 0 ]
}

@test "mkmf use builddir in Makefile" {
   run mkmf -b ${testDir}
   [ "$status" -eq 0 ]
   [ -e Makefile ]
   regexString="^BUILDROOT = ${testDir}/\$"
   run grep -q "${regexString}" Makefile
   [ "$status" -eq 0 ]
}

@test "mkmf include git version string cppdef" {
   run mkmf -g
   [ "$status" -eq 0 ]
   [ -e Makefile ]
   regexString='^CPPDEFS =  -D_FILE_VERSION=\\"`git-version-string $<`\\"$'
   run grep -q "${regexString}" Makefile
   [ "$status" -eq 0 ]
}

@test "mkmf accepts -I<INCLUDE> directories" {
   run mkmf -I${testDir}/src
   [ "$status" -eq 0 ]
   [ -e Makefile ]
}

@test "mkmf requires -I<INCLUDE> to exist and to be a directory" {
   run mkmf -I/this/does/not/exist
   [ "$status" -eq 2 ]
   run mkmf -I/dev/null
   [ "$status" -eq 25 ]
}

@test "mkmf finds include files in -I<INCLUDE>" {
   cat << EOF > test.F90
program test
  implicit none
#include <file4.inc>
  write (*,*) "Hello world."
end program test
EOF
   run mkmf -I${testDir}/src
   regexString="^\./file4\.inc: ${testDir}/src/file4\.inc\$"
   run grep -q "${regexString}" Makefile
   [ "$status" -eq 0 ]
}

@test "mkmf accepts -l \"linkflags\"" {
   run mkmf -l "-lextralib"
   [ "$status" -eq 0 ]
   [ -e Makefile ]
   regexString='\$(LD) \$(OBJ) -o a\.out -lextralib \$(LDFLAGS)'
   run grep -q "${regexString}" Makefile
   [ "$status" -eq 0 ]
}

@test "mkmf accepts -o \"other flags\"" {
   run mkmf -o "other flags"
   [ "$status" -eq 0 ]
   [ -e Makefile ]
   regexString='^OTHERFLAGS = other flags$'
   run grep -q "${regexString}" Makefile
}

@test "mkmf write to custom makefile" {
   run mkmf -m Makefile.test
   [ "$status" -eq 0 ]
   [ -e Makefile.test ]
}

@test "mkmf builds executable" {
   run mkmf -t ${mkmf_test_template} -c "-DSYMLINKS" ${testDir}/src
   [ "$status" -eq 0 ]
   [ -e Makefile ]
   run make
   [ "$status" -eq 0 ]
   [ -e a.out ]
   run ./a.out
   [ "$status" -eq 0 ]
   [ "$(echo "$output" | wc -l)" -eq 6 ]
}

@test "mkmf builds executable with -x option" {
   run mkmf -x -t ${mkmf_test_template} -c "-DSYMLINKS" ${testDir}/src
   [ "$status" -eq 0 ]
   [ -e Makefile ]
   [ -e a.out ]
   run ./a.out
   [ "$status" -eq 0 ]
   [ "$(echo "$output" | wc -l)" -eq 6 ]
}

@test "mkmf will call cpp on \*.F \*.F90 files" {
   run mkmf --use-cpp -x -t ${mkmf_test_template} -c "-DSYMLINKS" ${testDir}/src
   ls
   [ "$status" -eq 0 ]
   [ -e Makefile ]
   [ -e file1.DO_NOT_MODIFY.f90 ]
   [ -e a.out ]
   run ./a.out
   [ "$status" -eq 0 ]
   [ "$(echo "$output" | wc -l)" -eq 6 ]
}
   
@test "mkmf will use files from path_names file" {
   run list_paths ${testDir}/src
   [ "$status" -eq 0 ]
   [ -e path_names ]
   mkmf -x -t ${mkmf_test_template} path_names
   [ "$status" -eq 0 ]
   [ -e Makefile ]
   [ -e a.out ]
   run ./a.out
   [ "$status" -eq 0 ]
   [ "$(echo "$output" | wc -l)" -eq 5 ]
}

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

   # Locate the templates directory.
   # Prefer the conda-installed location ($PREFIX/share/mkmf/templates) when
   # running inside a conda build/test environment; fall back to the in-source
   # templates/ directory for normal repo usage.
   if [ -d "${PREFIX:-}/share/mkmf/templates" ]; then
       templateDir="${PREFIX}/share/mkmf/templates"
   else
       templateDir=$(readlink -f ${BATS_TEST_DIRNAME}/../templates)
   fi

   # Temporary directory where tests are run
   testDir=$(mktemp -d ${BATS_TEST_DIRNAME}/${BATS_TEST_NAME}.XXXXXXXX)
   cd ${testDir}
}

teardown() {
   rm -rf ${testDir}
}

helper() {
   run mkmf -t ${templateDir}/"$1"
   run make .DEFAULT
   echo "status = ${status}"
   echo "output = ${output}"
   [ "$status" -eq 0 ]
}

@test "template hpcme-intel2025.03-oneapi.mk" {
   helper hpcme-intel2025.03-oneapi.mk
}

@test "template hpcme-intel21.mk" {
   helper hpcme-intel21.mk
}

@test "template hpcme-intel23.mk" {
   helper hpcme-intel23.mk
}

@test "template hpcme-intel24.mk" {
   helper hpcme-intel24.mk
}

@test "template linux-gnu.mk" {
   helper linux-gnu.mk
}

@test "template linux-intel.mk" {
   helper linux-intel.mk
}

@test "template linux-ubuntu-trusty-gnu.mk" {
   helper linux-ubuntu-trusty-gnu.mk
}

@test "template linux-ubuntu-xenial-gnu.mk" {
   helper linux-ubuntu-xenial-gnu.mk
}

@test "template macOS-gnu8-mpich3.mk" {
   helper macOS-gnu8-mpich3.mk
}

@test "template nccs-intel.mk" {
   helper nccs-intel.mk
}

@test "template ncrc-nvhpc.mk" {
   helper ncrc-nvhpc.mk
}

@test "template ncrc4-cce.mk" {
   helper ncrc4-cce.mk
}

@test "template ncrc4-gcc.mk" {
   helper ncrc4-gcc.mk
}

@test "template ncrc4-intel.mk" {
   helper ncrc4-intel.mk
}

@test "template ncrc5-cce.mk" {
   helper ncrc5-cce.mk
}

@test "template ncrc5-gcc.mk" {
   helper ncrc5-gcc.mk
}

@test "template ncrc5-intel-classic.mk" {
   helper ncrc5-intel-classic.mk
}

@test "template ncrc5-intel-oneapi.mk" {
   helper ncrc5-intel-oneapi.mk
}

@test "template ncrc5-intel.mk" {
   helper ncrc5-intel.mk
}

@test "template osx-gnu.mk" {
   helper osx-gnu.mk
}

@test "template theia-intel.mk" {
   helper theia-intel.mk
}

@test "template triton-gnu.mk" {
   helper triton-gnu.mk
}

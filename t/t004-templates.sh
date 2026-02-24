#!/usr/bin/env bats

setup() {
   # set PATH if needed
   binDir=$(readlink -f ${BATS_TEST_DIRNAME}/../mkmf/bin)
   do_we_have_mkmf=$(which mkmf) || echo "no we do not!"
   if [ $do_we_have_mkmf ]; then
	   echo 'likely conda case'
   else
	   export PATH=${binDir}:${PATH}
   fi

   # test templates directory
   templateDir=$(readlink -f ${BATS_TEST_DIRNAME}/../templates)

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

@test "template ncrc-cray.mk" {
   helper ncrc-cray.mk
}

@test "template ncrc-gnu.mk" {
   helper ncrc-gnu.mk
}

@test "template ncrc-intel.mk" {
   helper ncrc-intel.mk
}

@test "template ncrc-pgi.mk" {
   helper ncrc-pgi.mk
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

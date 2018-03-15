#!/bin/sh

# Tests are written with relative paths to source and tools
testDir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# Get the binDir from testDir, and set PATH
binDir=$(dirname ${testDir})/bin
PATH=${binDir}:${PATH}
export PATH

# Other useful variables
srcDir=${testDir}/src
tmplDir=${testDir}/templates

# Create a build directory
buildDir=$(mktemp -d $(basename ${0}).XXXXXXXX)

# Get current PWD to return to this directory later.
startDir=$(pwd)

# Enter build directory to run tests
cd ${buildDir}

# Get the list of files
list_paths -o nolink_src.files ${srcDir}

# Create the Makefiles.  One for a library, and one for the program.
mkmf -p nolink_test -m Makefile -a $srcDir -b $buildDir -t ${tmplDir}/test_gnu.mk -g ${buildDir}/nolink_src.files

# Build the program
make nolink_test

# Run, and verify output
./nolink_test | tee test.output 2>&1
if [ $? -eq 0 ]
then
   numOutLines=$(wc -l test.output | awk '{print $1}')
else
   numOutLines=0
fi

cd ${startDir}

rm -rf ${buildDir}

if [ ${numOutLines} -eq 5 ]
then
   echo "Tests $(basename ${0}) Passed"
   exit 0
else
   echo "Tests $(basename ${0}) Failed"
   exit 1
fi

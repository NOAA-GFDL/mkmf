`mkmf`: Make Makefile
===================

[![CI](https://github.com/NOAA-GFDL/mkmf/workflows/build_conda/badge.svg)](https://github.com/NOAA-GFDL/mkmf/actions?query=workflow%3Abuild_conda)

__`mkmf`__ is a tool written in `perl5` that will construct a makefile
from distributed source. A single executable program is the typical
result, but I dare say it is extensible to a makefile for any purpose
at all.

__`mkmf`__ is pronounced make-make-file or make-m-f or even McMuff (Paul
Kushner's suggestion).

Features
--------

* Understands `f90` dependencies (modules and use), Fortran's
  `include` statement, and cpp's `#include` statement, in any type of
  source.
* No restrictions on filenames, module names, etc.
* Supports the concept of overlays (where source is maintained in
  layers of directories with a defined precedence).
* Keeps track of changes to `cpp` flags, and knows when to recompile
  affected source (i.e, files containing `#ifdefs` that have been
  changed since the last invocation).
* It is free, and released under GPL. 


Requirements
------------
`mkmf` and `list_paths` can be run on any unix type system that has
C-shell ([`tcsh`](http://www.tcsh.org/)) and `perl` version 5 installed.
`git-version-string` requires `git`. 

Usage as a `conda` package requires `conda`.

For testing, we recommend [`bats-core`](https://github.com/bats-core/bats-core),
a current and up-to-date (as of January 2025) fork of the original 
[`bats`](https://github.com/sstephenson/bats). Tests are run in the `build_conda`
github workflow automatically for PRs. To test locally by hand, simply call `bats`
and target the testing scripts in `t/` as desired from the root of this repository.

Installation
------------

### **(no `conda`)** install and use a copy of this repository
Clone the repository onto a file system with the aforementioned requirements.
Then and add the `mkmf/bin` directory to your shell's `$PATH`, like so:
```
git clone https://github.com/noaa-gfdl/mkmf.git mkmf && cd mkmf
export $PATH=$PWD/mkmf/bin:$PATH
```

### `conda env create` and use a copy of this repository
Similar to the previous approach, clone, but before adjusting `$PATH`, 
we create the `conda` environment named `mkmf` with all the required 
dependencies. To change the default name of the environment, edit the
first line in `environment.yaml`.
```
git clone https://github.com/noaa-gfdl/mkmf.git mkmf && cd mkmf
conda env create -y -f ./environment.yaml
conda activate mkmf
export $PATH=$PWD/mkmf/bin:$PATH
```

### install package from the `conda` channel into `conda` environment
Dissimilar from the aforementioned approaches, this requires no cloning,
nor any manual adjusting of `$PATH`. It just assumes your `conda` env of
choice is already activated. The package is retrieved from the `noaa-gfdl` 
conda channel.

The following line installs `mkmf` iinto the current environment, and 
handles everything:
```
conda activate existing_env
(existing_env) conda install noaa-gfdl::mkmf
```

### create a conda environment using the package from the channel
This approach creates a fresh, new environment with `mkmf` and all of 
it's dependencies, and requires no manual adjusting of `$PATH`
```
conda create -y -n env_name noaa-gfdl::mkmf
```


Disclaimer
==========

The United States Department of Commerce (DOC) GitHub project code is
provided on an "as is" basis and the user assumes responsibility for
its use. The DOC has relinquished control of the information and no
longer has responsibility to protect the integrity, confidentiality,
or availability of the information. Any claims against the Department
of Commerce stemming from the use of its GitHub project will be
governed by all applicable Federal law. Any reference to specific
commercial products, processes, or services by service mark,
trademark, manufacturer, or otherwise, does not constitute or imply
their endorsement, recommendation or favoring by the Department of
Commerce. The Department of Commerce seal and logo, or the seal and
logo of a DOC bureau, shall not be used in any manner to imply
endorsement of any commercial product or activity by DOC or the United
States Government.

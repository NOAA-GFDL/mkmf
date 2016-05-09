mkmf: Make Makefile
===================

__mkmf__ is a tool written in perl5 that will construct a makefile
from distributed source. A single executable program is the typical
result, but I dare say it is extensible to a makefile for any purpose
at all.


Features
--------

* Understands dependencies in f90 (modules and use), the Fortran
  include statement, and the cpp #include statement in any type of
  source
* No restrictions on filenames, module names, etc.
* Supports the concept of overlays (where source is maintained in
  layers of directories with a defined precedence)
* Keeps track of changes to cpp flags, and knows when to recompile
  affected source (i.e, files containing #ifdefs that have been
  changed since the last invocation);
* Will run on any unix platform that has perl version 5 installed
* It is free, and released under GPL. 


Pronunciation
-------------

__mkmf__ is pronounced make-make-file or make-m-f or even McMuff (Paul
Kushner's suggestion).


User guide
----------

### Syntax

mkmf [-a abspath] [-b bldpath] [-c cppdefs] [-o otherflags] [-l <linkflags>] [-I <linkpath>] [-d] [-f] [-g] [-m makefile] [-p program] [-t template] [-v] [-x] [args]

### Options

* __-a abspath__ attaches the __abspath__ at the _front_ of all
  _relative_ paths to source files.  If __-a__ is not specified, the
  current working directory is the __abspath__.
* __-b bldpath__ Adds a make macro __BUILDROOT__ set to __bldpath__,
  and replaces the __bldpath__ with __$(BUILDROOT)__ in all source and
  include paths.
* __-c cppdefs__ is a list of __cpp #defines__ to be passed to the
  source files: affected object files will be selectively removed if
  there has been a change in this state.
* __-o otherflags__ is a list of compiler directives to be passed to
  the source files: it is rather similar to __cppdefs__ except that
  these can be any flags. Also, by Fortran convention, cpp is only
  invoked on .F and .F90 files; __otherflags__ apply to all source
  files (.f and .f90 as well).
* __-l linkflags__ is a string of link directives to be passed to the
  link command in the makefile.
* __-I includepath__ is a path that contains include files.  This is
  similar to how _-I_ is used by most compilers.
* __-d__ is a debug flag to __mkmf__ (much more verbose than __-v__,
  but probably of use only if you are modifying __mkmf__ itself).
* __-f__ is a formatting flag to restrict lines in the makefile to 256
  characters.
* __-g__ Include ``-D_FILE_VERSION="`git-version-string $<`"`` in the
  compile command line.
* __-m makefile__ is the name of the makefile written (default
  _Makefile_)
* __-t template__ is a file containing a list of make macros or
  commands written to the beginning of the makefile.
* __-p program__ is the name of the final target (default _a.out_).
  If __program__ has the file extension _.a_, it is understood to be a
  library. The command to create it is `$(AR) $(ARFLAGS) instead of
  $(LD) $(LDFLAGS)`.
* __-v__ is a verbosity flag to mkmf.
* __-x__ executes the makefile immediately.
* __args__ are a list of directories and files to be searched for
  targets and dependencies.

### Makefile structure

A _sourcefile_ is any file with a source file suffix (currently .F,
.F90, .f., .f90, .c, .C, .cc, .cp, .cxx, c++). An _includefile_ is any
file with an include file suffix (currently .H, .fh, .h, .h90, .inc).
A valid _sourcefile_ can also be an _includefile_.

Each _sourcefile_ in the list is presumed to produce an object file
with the same _basename_ and a _.o_ extension in the current working
directory.  If more than one _sourcefile_ in the list would produce
identically-named object files, only the first is used and the rest
are discarded.  This permits the use of overlays: if _dir3_ contained
the basic source code, _dir2_ contained bug fixes, and _dir1_
contained mods for a particular build, `mkmf dir1 dir2 dir3` would
create a makefile for correct compilation.  Please note that
precedence _descends_ from left to right.  This is the conventional
order used by compilers when searching for libraries, includes, etc:
left to right along the command line, with the first match
invalidating all subsequent ones. See the [Examples](#examples)
section for a closer look at precedence rules.

The makefile currently runs `$(FC)` on Fortran files, `$(CC)` on C
files, and `$(CXX)` on C++ files.  Flags to the compiler can be set in
`$(FFLAGS)` or `$(CFLAGS)`.  The final loader step executes `$(LD)`.
Flags to the loader can be set in $(LDFLAGS).  Libraries are archived
using `$(AR)`, with flags set in `$(ARFLAGS)`.  Preprocessor flags are
used by .F, .F90 and .c files, and can be set in $(CPPFLAGS).  These
macros have a default meaning on most systems, and can be modified in
the template file. The predefined macros can be discovered by running
`make -p`.

In addition, the macro `$(CPPDEFS)` is applied to the preprocessor.
This can contain the cpp `#defines` which may change from run to run.
cpp options that do not change between compilations should be placed
in $(CPPFLAGS).

Includefiles are recursively searched for embedded includes.

For emacs users, the make target _TAGS_ is always provided.  This
creates a TAGS file in the current working directory with a
cross-reference table linking all the sourcefiles. If you don't know
about emacs tags, please consult the emacs help files!  It is an
incredibly useful feature.

The default action for non-existent files is to _touch_ them (i.e
create null files of that name) in the current working directory.

All the object files are linked to a single executable.  It is
therefore desirable that there be a single main program source among
the arguments to __mkmf__, otherwise, the loader is likely to
complain.

### Treatment of [args]

The argument list __args__ is treated sequentially from left to right.
Arguments can be of three kinds:

1. If an argument is a sourcefile, it is added to the list of
   sourcefiles.
2. If an argument is a directory, all the sourcefiles in that
   directory are added to the list of sourcefiles.
3. If an argument is a regular file, it is presumed to contain a list
   of sourcefiles.  Any line not containing a sourcefile is discarded.
   If the line contains more than one word, the last word on the line
   should be the sourcefile name, and the rest of the line is a
   file-specific compilation command.  This may be used, for instance,
   to provide compiler flags specific to a single file in the
   sourcefile list:
        a.f90
        b.f90
        f90 -Oaggress c.f90
  This will add `a.f90`, `b.f90` and `c.f90` to the sourcefile
  list. The first two files will be compiled using the generic command
  `$(FC) $(FFLAGS)`.  But when the make requires `c.f90` to be
  compiled, it will be compiled with f90 -Oaggress.

The directory abspath (specified by __-a abspath__), or the current
working directory, is always the first (and top-precedence) argument,
even if __args__ is not supplied.

### Treatment of [-c cppdefs]

The argument __cppdefs__ is treated as follows.  __cppdefs__ should
contain a comprehensive list of the cpp `#defines` to be preprocessed.
This list is compared against the current "state", maintained in the
file `.cppdefs` in the current working directory.  If there are any
changes to this state, __mkmf__ will remove all object files affected
by this change, so that the subsequent make will recompile those
files.

The file __.cppdefs__ is created if it does not exist.  If you wish to
edit it by hand (don't!) it merely contains a list of the cpp flags
separated by blanks, in a single record, with no newline at the end.

__cppdefs__ also sets the make macro `CPPDEFS`.  If this was set in a
template file and also in the __-c__ flag to __mkmf__, the value in
__-c__ takes precedence.  Typically, you should set only `CPPFLAGS` in
the template file, and `CPPDEFS` via __mkmf -c__.

### Treatment of includefiles

Include files are often specified without an explicit path, e.g

     #include "config.h"

or:

     #include <config.h>

By convention, the first form will take a file of that name found in
the _same_ directory as the source, before looking at include
directories specified by -I. The second form ignores the local
directory and only uses -I.

__mkmf__ does not currently distinguish between the two forms of
include.  It first attempts to locate the includefile in the same
directory as the source file.  If it is not found there, it looks in
the directories listed as arguments, maintaining the same
left-to-right precedence as described above.

This follows the behaviour of most f90 compilers: includefiles inherit
the path to the source, or else follow the order of include
directories specified from left to right on the f90 command line, with
the -I flags descending in precedence from left to right.  It's
possible there are compilers that violate the rule.  If you come
across any, please bring that to my attention.

If you have includefiles in a directory __dir__ other than those
listed above, you can specify it yourself by including `-Idir` in
`$(FFLAGS)` in your template file.  Includepaths in the template file
take precedence over those generated by __mkmf__.  (I suggest using
`FFLAGS` for this rather than `CPPFLAGS` because Fortran includes can
occur even in source requiring no preprocessing).

### Examples

The template file using the Intel compilers:

```makefile
CC = icc
FC = ifort
CXX = icpc
LD = ifort

CPPFLAGS = -O2 -sox
CFLAGS = -O2 -sox
FFLAGS = -i4 -i8 -sox -O2
LDFLAGS = $(LIBS)
LIST = -listing
```

The meaning of the various flags may be divined by reading the
manual. A line defining the make macro LIBS, e.g:

```makefile
LIBS = -lmpi
```

may be added anywhere in the template to have it added to the link
command line.

This example illustrates the effective use of __mkmf__'s precedence
rules.  Let the current working directory contain a file named
`path_names` containing the lines:
     updates/a.f90
     updates/b.f90

The directory `/home/src/base` contains the files:
     a.f90
     b.f90
     c.f90

Typing
     mkmf path_names /home/src/base
produces the following Makefile:

```makefile
# Makefile created by mkmf


.DEFAULT:
	-touch $@
all: a.out
c.o: /home/src/base/c.f90
	$(FC) $(FFLAGS) -c	/home/src/base/c.f90
a.o: updates/a.f90
	$(FC) $(FFLAGS) -c	updates/a.f90
b.o: updates/b.f90
	$(FC) $(FFLAGS) -c	updates/b.f90
./c.f90: /home/src/base/c.f90
	cp /home/src/base/c.f90 .
./a.f90: updates/a.f90
	cp updates/a.f90 .
./b.f90: updates/b.f90
	cp updates/b.f90 .
SRC = /home/src/base/c.f90 updates/a.f90 updates/b.f90
OBJ = c.o a.o b.o
OFF = /home/src/base/c.f90 updates/a.f90 updates/b.f90
clean: neat
	-rm -f .cppdefs $(OBJ) a.out
neat:
	-rm -f $(TMPFILES)
localize: $(OFF)
	cp $(OFF) .
TAGS: $(SRC)
	etags $(SRC)
tags: $(SRC)
	ctags $(SRC)
a.out: $(OBJ)
	$(LD) $(OBJ) -o a.out $(LDFLAGS)
```

Note that when files of the same name recur in the target list, the
files in the updates directory (specified in `path_names`) are used
rather than those in the base source repository `/home/src/base`.

Assume that now you want to test some changes to `c.f90`. You don't
want to make changes to the base source repository itself prior to
testing; so you make yourself a local copy.
     make ./c.f90
You didn't even need to know where c.f90 originally was.

Now you can make changes to your local copy ./c.f90. To compile using
your changed copy, type:
     mkmf path_names /home/src/base
     make
The new Makefile looks like this:

```makefile
# Makefile created by mkmf


.DEFAULT:
	-touch $@
all: a.out
c.o: c.f90
	$(FC) $(FFLAGS) -c	c.f90
a.o: updates/a.f90
	$(FC) $(FFLAGS) -c	updates/a.f90
b.o: updates/b.f90
	$(FC) $(FFLAGS) -c	updates/b.f90
./a.f90: updates/a.f90
	cp updates/a.f90 .
./b.f90: updates/b.f90
	cp updates/b.f90 .
SRC = c.f90 updates/a.f90 updates/b.f90
OBJ = c.o a.o b.o
OFF = updates/a.f90 updates/b.f90
clean: neat
	-rm -f .cppdefs $(OBJ) a.out
neat:
	-rm -f $(TMPFILES)
localize: $(OFF)
	cp $(OFF) .
TAGS: $(SRC)
	etags $(SRC)
tags: $(SRC)
	ctags $(SRC)
a.out: $(OBJ)
	$(LD) $(OBJ) -o a.out $(LDFLAGS)
```

Note that you are now using your local copy of `c.f90` for the
compile, since the files in the current working directory always take
precedence.  To revert to using the base copy, just remove the local
copy and run __mkmf__ again.

This illustrates the use of mkmf -c:
     mkmf -c "-Dcppflag -Dcppflag2=2 -Dflag3=string ..."
	 
will set `CPPDEFS` to this value, and also save this state in the file
`.cppdefs`.  If the argument to __-c__ is changed in a subsequent
call:
     mkmf -c "-Dcppflag -Dcppflag2=3 -Dflag3=string ..."
__mkmf__ will scan the source list for sourcefiles that make
references to cppflag2, and the corresponding object files will be
removed.

### Caveats

In F90, the module name must occur on the same source line as the
module or use keyword. That is to say, if your code contained:

```fortran
use &
   this_module
```

it would confuse __mkmf__. Similarly, a Fortran include statement must
not be split across lines.

Two use statements on the same line is not currently recognized, that
is:

```fortran
use module1; use module2
```

is to be avoided.

Currently the default action for files listed as dependencies but not
found: in this case, I touch the file, creating a null file of that
name in the current directory.  This may not be the correct method,
but it is currently the least annoying way to take care of a situation
when cpp `#includes` buried within obsolete `#ifdefs` ask for files
that don't exist:

```fortran
#ifdef obsolete
#include "nonexistent.h"
#endif
```

If the formatting flag -f is used, long lines will be broken up at
intervals of 256 characters. This can lead to problems if individual
paths are longer than 256 characters.

BUGS
------
Please report issues on the project's github page
https://github.com/NOAA-GFDL/mkmf

AUTHORS
-------

Designed and written by
V. Balaji.

COPYRIGHT
---------

Copyright 1999-2013 V. Balaji

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see L<http://www.gnu.org/licenses/>.

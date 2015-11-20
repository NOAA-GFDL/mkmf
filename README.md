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

Installation
------------

*mkmf* and *list_paths* can be run on any \*nix type system that has C-shell ([tcsh](http://www.tcsh.org/)) and Perl version 5 installed.

To install, place the repository on the file system and add the bin directory to PATH.

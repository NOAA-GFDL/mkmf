# template for the pathscale compiler on a Cray system
# typical use with mkmf
# mkmf -t ncrc-pathscale.mk -c"-Duse_libMPI -Duse_netCDF" path_names /usr/local/include
############
# commands #
############
FC = ftn
CC = cc
CXX = CC
LD = ftn $(MAIN_PROGRAM)
#########
# flags #
#########
DEBUG =
REPRO =
VERBOSE =
OPENMP =

##############################################
# Need to use at least GNU Make version 3.81 #
##############################################
need := 3.81
ok := $(filter $(need),$(firstword $(sort $(MAKE_VERSION) $(need))))
ifneq ($(need),$(ok))
$(error Need at least make version $(need).  Load module gmake/3.81)
endif

#################################################################
# site-dependent definitions, set by environment                #
#################################################################

NETCDF_ROOT = $(CRAY_NETCDF_DIR)/netcdf-pathscale
MPI_ROOT    = $(MPICH_DIR)
INCLUDE = -I$(NETCDF_ROOT)/include

FPPFLAGS = $(INCLUDE)
FFLAGS = -i4 -r8 -byteswapio -fno-second-underscore
FFLAGS_OPT = -O3 -OPT:fast_math=on:Olimit=0:IEEE_arith=2 -TENV:X=1
FFLAGS_DEBUG = -g -trapuv -TENV:simd_zmask=OFF:simd_umask=OFF
FFLAGS_REPRO = -O2 -OPT:fast_math=off:Olimit=0 -TENV:X=1
FFLAGS_OPENMP = -mp
FFLAGS_VERBOSE = -v

CPPFLAGS = $(INCLUDE)
CFLAGS =
CFLAGS_OPT = -O2
CFLAGS_DEBUG = -g
CFLAGS_OPENMP = -mp
CFLAGS_VERBOSE = -v

# Optional Testing compile flags.  Mutually exclusive from DEBUG, REPRO, and OPT
# *_TEST will match the production if no new option(s) is(are) to be tested.
FFLAGS_TEST = -O3 -OPT:fast_math=on:Olimit=0:IEEE_arith=2 -TENV:X=1
CFLAGS_TEST = -O2

# pathscale wants main program outside libraries, do
# setenv MAIN_PROGRAM coupler_main.o or something before make
LDFLAGS := -byteswapio
LDFLAGS_VERBOSE := -v

MAKEFLAGS +=--jobs=2

ifneq ($(REPRO),)
CFLAGS += $(CFLAGS_REPRO)
FFLAGS += $(FFLAGS_REPRO)
else ifneq ($(DEBUG),)
CFLAGS += $(CFLAGS_DEBUG)
FFLAGS += $(FFLAGS_DEBUG)
else ifneq ($(TEST),)
CFLAGS += $(CFLAGS_TEST)
FFLAGS += $(FFLAGS_TEST)
else
FFLAGS += $(FFLAGS_OPT)
CFLAGS += $(CFLAGS_OPT)
endif

ifneq ($(OPENMP),)
CFLAGS += $(CFLAGS_OPENMP)
FFLAGS += $(FFLAGS_OPENMP)
endif

ifneq ($(VERBOSE),)
CFLAGS += $(CFLAGS_VERBOSE)
FFLAGS += $(FFLAGS_VERBOSE)
LDFLAGS += $(LDFLAGS_VERBOSE)
endif

# add LIBS at the end
LIBS := -L$(NETCDF_ROOT)/lib
ifeq ($(NETCDF),3)
# add the use_LARGEFILE cppdef
ifneq ($(findstring -Duse_netCDF,$(CPPDEFS)),)
CPPDEFS += -Duse_LARGEFILE
endif
LIBS += -lnetcdf
else
LIBS += -lnetcdff -lnetcdf -lhdf5_hl -lhdf5 -lz
endif
LDFLAGS += $(LIBS)

#---------------------------------------------------------------------------
# you should never need to change any lines below.

# see the MIPSPro F90 manual for more details on some of the file extensions
# discussed here.
# this makefile template recognizes fortran sourcefiles with extensions
# .f, .f90, .F, .F90. Given a sourcefile <file>.<ext>, where <ext> is one of
# the above, this provides a number of default actions:

# make <file>.opt	create an optimization report
# make <file>.o		create an object file
# make <file>.s		create an assembly listing
# make <file>.x		create an executable file, assuming standalone
#			source
# make <file>.i		create a preprocessed file (for .F)
# make <file>.i90	create a preprocessed file (for .F90)

# The macro TMPFILES is provided to slate files like the above for removal.

RM = rm -f
SHELL = /bin/csh -f
TMPFILES = .*.m *.B *.L *.i *.i90 *.l *.s *.mod *.opt

.SUFFIXES: .F .F90 .H .L .T .f .f90 .h .i .i90 .l .o .s .opt .x

.f.L:
	$(FC) $(FFLAGS) -c -listing $*.f
.f.opt:
	$(FC) $(FFLAGS) -c -opt_report_level max -opt_report_phase all -opt_report_file $*.opt $*.f
.f.l:
	$(FC) $(FFLAGS) -c $(LIST) $*.f
.f.T:
	$(FC) $(FFLAGS) -c -cif $*.f
.f.o:
	$(FC) $(FFLAGS) -c $*.f
.f.s:
	$(FC) $(FFLAGS) -S $*.f
.f.x:
	$(FC) $(FFLAGS) -o $*.x $*.f *.o $(LDFLAGS)
.f90.L:
	$(FC) $(FFLAGS) -c -listing $*.f90
.f90.opt:
	$(FC) $(FFLAGS) -c -opt_report_level max -opt_report_phase all -opt_report_file $*.opt $*.f90
.f90.l:
	$(FC) $(FFLAGS) -c $(LIST) $*.f90
.f90.T:
	$(FC) $(FFLAGS) -c -cif $*.f90
.f90.o:
	$(FC) $(FFLAGS) -c $*.f90
.f90.s:
	$(FC) $(FFLAGS) -c -S $*.f90
.f90.x:
	$(FC) $(FFLAGS) -o $*.x $*.f90 *.o $(LDFLAGS)
.F.L:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -c -listing $*.F
.F.opt:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -c -opt_report_level max -opt_report_phase all -opt_report_file $*.opt $*.F
.F.l:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -c $(LIST) $*.F
.F.T:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -c -cif $*.F
.F.f:
	$(FC) $(CPPDEFS) $(FPPFLAGS) -EP $*.F > $*.f
.F.i:
	$(FC) $(CPPDEFS) $(FPPFLAGS) -P $*.F
.F.o:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -c $*.F
.F.s:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -c -S $*.F
.F.x:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -o $*.x $*.F *.o $(LDFLAGS)
.F90.L:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -c -listing $*.F90
.F90.opt:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -c -opt_report_level max -opt_report_phase all -opt_report_file $*.opt $*.F90
.F90.l:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -c $(LIST) $*.F90
.F90.T:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -c -cif $*.F90
.F90.f90:
	$(FC) $(CPPDEFS) $(FPPFLAGS) -EP $*.F90 > $*.f90
.F90.i90:
	$(FC) $(CPPDEFS) $(FPPFLAGS) -P $*.F90
.F90.o:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -c $*.F90
.F90.s:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -c -S $*.F90
.F90.x:
	$(FC) $(CPPDEFS) $(FPPFLAGS) $(FFLAGS) -o $*.x $*.F90 *.o $(LDFLAGS)

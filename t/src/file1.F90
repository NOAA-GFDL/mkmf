program main
  ! This is a simple program to verify mkmf and list_paths get the correct sources
  ! to build the application.
  !
  ! The output from the application should simply contain a series of printouts
  ! that the subroutines from different modules ran correctly.

  use file2_mod, only: file2_ok, file5_ok
#ifdef SYMLINKS
  ! Will be called only when testing list_path's ability to find symbolic links
  use file6_mod, only: file6_ok
#endif
  ! For C/Fortran interop
  use ISO_C_BINDING
  
  implicit none
  
  interface
     ! Interface for file3.f
     subroutine file3_ok()
     end subroutine file3_ok
  end interface

  ! Interface for the c function
#include "file4.inc"
  
  integer :: cfuncout
  
  write (*,*) "Ok from main in file1.F90"
  call file2_ok()
  call file3_ok()
  cfuncout =  file4_ok()
  call file5_ok()
#ifdef SYMLINKS
  call file6_ok()
#endif
end program main

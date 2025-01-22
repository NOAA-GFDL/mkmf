module file2_mod
  use file5_mod, only: file5_ok
  implicit none
  public file2_ok, file5_ok
contains
  subroutine file2_ok()
    write (*,*) "Ok from file2_ok in file2.F90"
  end subroutine file2_ok
end module file2_mod

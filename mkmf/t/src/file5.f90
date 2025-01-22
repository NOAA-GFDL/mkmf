module file5_mod
  implicit none
  public file5_ok
contains

  subroutine file5_ok
    write (*,*) "Ok from file5_ok in file5.90"
  end subroutine file5_ok
end module file5_mod

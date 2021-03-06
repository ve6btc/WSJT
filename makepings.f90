subroutine makepings(iwave,nwave)

  integer*2 iwave(nwave)
  real*8 t

  iping0=-999
  dt=1.0/11025.0

  w=1.                                         !Silence compiler warnings ...
  t0=1.
  amp=1.                                       !... to here

  do i=1,nwave
     iping=i/(3*11025)
     if(iping.ne.iping0) then
        ip=mod(iping,3)
        w=0.015*(4-ip)
        ig=(iping-1)/3
        amp=sqrt((3.0-ig)/3.0)
        t0=dt*(iping+0.5)*(3*11025)
        iping0=iping
     endif
     t=(i*dt-t0)/w
     if(t.lt.0.d0 .and. t.lt.10.0) then
        fac=0.
     else
        fac=2.718*t*dexp(-t)
     endif
     iwave(i)=nint(fac*amp*iwave(i))
  enddo

  return
end subroutine makepings

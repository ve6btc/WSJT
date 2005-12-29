      subroutine flat1(psavg,s2,nh,nsteps,nhmax,nsmax)

      real psavg(nh)
      real s2(nhmax,nsmax)
      real x(4096),tmp(33)

      nsmo=33
      ia=nsmo/2 + 1
      ib=nh - nsmo/2 - 1
      do i=ia,ib
         call pctile(psavg(i-nsmo/2),tmp,nsmo,50,x(i))
      enddo
      do i=1,ia-1
         x(i)=x(ia)
      enddo
      do i=ib+1,nh
         x(i)=x(ib)
      enddo

      do i=1,nh
         psavg(i)=psavg(i)/x(i)
         do j=1,nsteps
            s2(i,j)=s2(i,j)/x(i)
         enddo
      enddo

      return
      end

      

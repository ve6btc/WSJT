subroutine decode3(d2,jz,istart,filename)

  integer*2 d2(jz),d2d(125*11025)
  character*24 filename
  character FileID*40
  include 'gcom1.f90'
  include 'gcom2.f90'

  if(ichar(filename(1:1)).eq.0) go to 999
    
  FileID=filename
  decodedfile=filename
  lumsg=11
  nmode=1
  if(mode(1:4).eq.'JT65') then
     nmode=2
     if(mode(5:5).eq.'A') mode65=1
     if(mode(5:5).eq.'B') mode65=2
     if(mode(5:5).eq.'C') mode65=4
  endif
  nfast=1
  if(mode.eq.'JT65B2' .or. mode.eq.'JT65C2') nfast=2
  if(mode(1:4).eq.'Echo') nmode=3
  if(mode(1:4).eq.'JT6M') nmode=4
  if(mode(1:2).eq.'CW') nmode=5
  if(mode(1:3).eq.'JT4') nmode=7
  if(mode(1:4).eq.'JTMS') nmode=8
  if(mode(1:5).eq.'ISCAT') nmode=9
  sum=0.
  do i=1,jz
     sum=sum+d2(i)
  enddo
  nave=nint(sum/jz)
  do i=1,jz
     d2(i)=d2(i)-nave
     d2d(i)=d2(i)
  enddo

  nseg=1
  if(mode(1:4).eq.'JT65' .or. nmode.ge.6) then
     i=index(FileID,'.')-3
     if(FileID(i:i).eq.'1'.or.FileID(i:i).eq.'3'.or.FileID(i:i).eq.'5'  &
          .or.FileID(i:i).eq.'7'.or.FileID(i:i).eq.'9') nseg=2
  endif

  open(23,file=appdir(:lenappdir)//'/CALL3.TXT',status='unknown')
  if(nadd5.eq.1) then
!  Insert 5 s of zeroes at start of data.
     nzero=5*11025
     do i=jz,nzero+1,-1
        d2d(i)=d2d(i-nzero)
     enddo
     do i=1,nzero
        d2d(i)=0
     enddo
     jz=min(60*11025,jz+nzero)
  endif
  mb0=mousebutton
  if(jz.gt.14*11025) call dtrim(d2d,jz)
  nfast=1
  if(mode.eq.'JT65B2' .or. mode.eq.'JT65C2') nfast=2
  if(mode(1:3).eq.'FSK') then
     if(mode(4:6).eq.'315') then
         mode65 = 1
     else
         mode65 = 0
     endif
  endif
  call wsjt1(d2d,jz,istart,samfacin,FileID,ndepth,degrade,             &
       MinSigdB,DFTolerance,MouseButton,NClearAve,nforce,              &
       nMode,NFreeze,NAFC,NZap,mode65,nfast,mode4,minwidth,idf,        &
       ntdecode,MyCall,HisCall,HisGrid,neme,ntx2,ndebug,s2,            &
       ps0,npkept,lumsg,nslim2,psavg,ccf,Nseg,                         &
       MouseDF,NAgain,LDecoded,nspecial,ndf,ss1,ss2)
  nforce=0
  ntx2=0
  close(23)

! See whether this file should be saved or erased from disk
  if(nsave.eq.1 .and. ldecoded) filetokilla=''
  if(nsave.eq.3 .or. (nsave.eq.2 .and. lauto.eq.1)) then
     filetokilla=''
     filetokillb=''
  endif
  if(nsavelast.eq.1) filetokillb=''
  nsavelast=0
  ierr=unlink(filetokillb)
  
  nclearave=0
  nagain=0
  if(mode(1:4).eq.'JT65' .or. mode(1:3).eq.'JT4') then
     call pix2d65(d2d,jz)
  else if(mode(1:3).eq.'FSK' .or. mode(1:4).eq.'JTMS') then
     nz=s2(1,1)
     if(nz.gt.0) call pix2d(d2d,jz,mb0,mousedf,nfreeze,mode,s2,64,nz,b)
  else if(mode(1:4).eq.'JT6M' .and. mousebutton.eq.0) then
     nz=s2(1,1)
!     if(nz.gt.0) call pix2d(d2d,jz,mousebutton,MouseDF,NFreeze,mode,   &
!          s2,64,nz,b)
     if(nz.gt.0) call pix2d(d2d,jz,mb0,mousedf,nfreeze,mode,s2,64,nz,b)
  else if(mode(1:5).eq.'ISCAT' .and. mb0.le.1) then
     nz=s2(1,1)
     if(nz.gt.0) call pix2d(d2d,jz,mb0,mousedf,nfreeze,mode,s2,64,nz,b)
  endif

! Compute red and magenta cutves for small plot area, FSK441/JTMS only
  if(mode(1:3).eq.'FSK' .or. mode.eq.'JT6M' .or. mode.eq.'JTMS') then
     do i=1,128
        if((mode(1:3).eq.'FSK' .or. mode.eq.'JTMS')                      &
             .and. ps0(i).gt.0.0) ps0(i)=10.0*log10(ps0(i))
        if(psavg(i).gt.0.0) psavg(i)=10.0*log10(psavg(i))
     enddo
  endif

999 return
end subroutine decode3

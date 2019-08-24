pro despiker_raponi, img

  
   ;**********parameters to set ***************
   nmax = 8 ; n max adjacent spectel to cut
   box = 5; ;2 x box + 1 = n pixel adjacent to the target pixel to analyse simultaneously
   ns = 4 ; n sigma = threshold (spike or not?)
   n_max_spikes = 20 ;n max spikes in the spectrum, if larger then no spikes are cutted 
;***************************************

   dir = '' ; the directory where data are located
   list_dat = file_search(dir,'*') ; file name search: it can despike more all cubes in the dir with the label indicated
  
 
 
;   
   ;************ read wavelength ******************

   wavelength = 'XXX\VIRTIS_M_IR_lambda.txt'  ;put here your wavelegth path
   readcol, wavelength, wave, format='f' 
;  WAVE = WAVE/1000. ;if required


for ii=0,n_elements(list_dat)-1 do begin



   file = strmid(list_dat(ii),0,strlen(list_dat(ii))-4)
   ;*********** read header  ****************************** ;it can be different from yours
   openr, lun, file+'.hdr',/get_lun
   row = ''
   linegood = 0
   argument = ''
   value = ''
   samples = 0.
   lines = 0.
   bands = 0.
   line=0
   sample=0

   while not eof(lun) do begin
      readf, lun, row
      linegood = strmatch(row,'*=*', /fold_case)
      if linegood eq 1 then begin      
         linesplit = strsplit(row,'=')      
         argument = strmid(row,linesplit(0),linesplit(1)-1)
         argument = strcompress(argument,/remove_all)
         value = strmid(row,linesplit(1))
         value = strcompress(value,/remove_all)      
         if argument eq 'samples' then samples = fix(value) 
         if argument eq 'lines' then lines = fix(value) 
         if argument eq 'bands' then bands = fix(value) 
         if argument eq 'interleave' then interleave = value
      endif
   endwhile 
   print,samples,lines,bands,interleave    
   free_lun,lun
   cube = fltarr(bands,samples,lines)
   cube_read = fltarr(bands,samples,lines)

   openr, lun, list_dat(ii),/get_lun
   readu, lun, cube_read
   free_lun,lun
   cube = cube_read

   nan = where(finite(cube) ne 1)
   if nan ne [-1] then cube(nan) = 0.
   
   cube_desp = cube


   x=indgen(bands)
   cube_der = fltarr(bands,samples,lines)
   cube_der_med = fltarr(bands,samples,lines)
   cube_sigmas = fltarr(bands,samples,lines)
   cube_box_der = fltarr(bands,samples,lines)
   

   
   lines_fix = lines
   samples_fix = samples

   ;************to eliminate values < 0.. You might want to skip it
   
   for l=line,lines-1 do begin
     print,'   '+strtrim(l,2)+' / '+strtrim(lines-1,2)+' -  1 / 3'
     for s=sample,samples-1 do begin
     
       slit = reform(cube(*,s,l))
       slit_desp = slit
      
  
       spike = 0
       count = 0
       for n=1,bands-1 do begin
          if slit(n) lt 0. and spike eq 0 and slit(n-1) gt 0. then begin
             inf = n-1
             spike = 1
          endif         
          if spike eq 1 and slit(n) gt 0. then begin           
             coeff = linfit([x(inf),x(n)],[slit(inf),slit(n)])
             slit_desp(inf:n) = coeff(0)+coeff(1)*x(inf:n)
             spike = 0
             count = 0
          endif
       endfor
       cube(*,s,l) = slit_desp
    endfor
   endfor
  ;***********************************************************
    


   ;derivatives
   for n=1,bands-1 do cube_der(n,*,*) = (cube(n,*,*)-cube(n-1,*,*))
             


;*****************analysis in 1 spatial dimension *************************************
   for l=line,lines-1 do begin
     print,'   '+strtrim(l,2)+' / '+strtrim(lines-1,2)+' -  2 / 3'
     for s=sample,samples-1 do begin
        ll = l
        ss = s

        if l lt box then ll = box
        if l gt lines_fix-box-1 then ll = lines_fix-box-1

        for n=1,bands-1 do begin
          box_der = cube_der(n,ss,ll-box:ll+box)
          median_box_der = median(box_der)
          cube_der_med(n,s,l) = cube_der(n,s,l)-median_box_der
          cube_sigmas(n,s,l) = median(abs(box_der))
          cube_box_der(n,s,l) = median_box_der
        endfor
     endfor
   endfor
   
   ;DESPIKER
; *****************************************************************************
   
   for l=line,lines-1 do begin
     print,'   '+strtrim(l,2)+' / '+strtrim(lines-1,2)+' -  3 / 3'
     for s=sample,samples-1 do begin
    
     spikes = 0
     
       slit = reform(cube(*,s,l))
       slit_desp = slit
     
       der = cube_der_med(*,s,l)
       
;       der = der-median(der) ;do not uncomment this
       sigmas = cube_sigmas(*,s,l)
      


       spike = 0
       der_cum = 0. 
       der_tot = 0.
       count = 0
       for nn=0,bands-nmax-1 do begin
          control = ns*sigmas(nn:nmax+nn) - abs(der(nn:nmax+nn))
          arr =where(control lt 0.)
          if arr eq [-1] then break
      endfor

       
       for n=nn,bands-1 do begin

          if abs(der(n)) gt ns*sigmas(n) and spike eq 0 then begin
             inf = n-1
             spike = 1            
          endif
          if spike eq 1 then der_tot = der_tot + der(n)          
          if abs(der(n)) gt ns*sigmas(n) and spike eq 1 and n ne bands-1 then begin
             der_cum = der_cum + der(n)  
             sigmean = ns*sqrt(total(sigmas(n-count:n)^2))         
             if abs(der_cum) lt sigmean and abs(der_tot) lt sigmean and count gt 0 and abs(der(n+1)) lt ns*sigmas(n+1) then begin
                coeff = linfit([x(inf),x(n)],[slit_desp(inf),slit_desp(n)])
                slit_desp(inf:n) = coeff(0)+coeff(1)*x(inf:n)
                spike = 0
                der_cum = 0.
                der_tot = 0.
                count = 0
                spikes = spikes+1                
             endif
          endif
          if abs(der(n)) gt ns*sigmas(n) and spike eq 1 and n eq bands-1 then begin
             der_cum = der_cum + der(n)  
             sigmean = ns*sqrt(total(sigmas(n-count:n)^2))         
             if abs(der_cum) lt sigmean and abs(der_tot) lt sigmean and count gt 0 then begin
                coeff = linfit([x(inf),x(n)],[slit_desp(inf),slit_desp(n)])
                slit_desp(inf:n) = coeff(0)+coeff(1)*x(inf:n)
                spike = 0
                der_cum = 0.
                der_tot = 0.
                count = 0
                spikes = spikes+1
             endif 
          endif
          if spike eq 1 and n eq bands-1 then slit_desp(inf+1:n) = slit_desp(inf)+total(cube_box_der(inf+1:n,s,l),/cumulative)
          if spike eq 1 then begin
             count=count+1
             if n ne bands-1 then begin
             if count gt nmax and abs(der(n+1)) lt ns*sigmas(n+1) then begin
                der_cum = 0.
                der_tot = 0.
                spike = 0
                count = 0
                n = inf+1
             endif
             endif
          endif
       endfor
 ;********************despiker reverse ***************************************      
       spike = 0
       der_cum = 0. 
       der_tot = 0.
       count = 0
       if nn ne 1 then begin

          for n=nn+1,0,-1 do begin
            if abs(der(n)) gt ns*sigmas(n) and spike eq 0 then begin
               sup = n
               spike = 1
            endif
            if spike eq 1 then der_tot = der_tot + der(n)
            if abs(der(n)) gt ns*sigmas(n) and spike eq 1 and n ne 0 then begin
               der_cum = der_cum + der(n)
               sigmean = ns*sqrt(total(sigmas(n:n+count)^2))
               if abs(der_cum) lt sigmean and abs(der_tot) lt sigmean and count gt 0 and abs(der(n-1)) lt ns*sigmas(n-1)  then begin
                  coeff = linfit([x(n-1),x(sup)],[slit_desp(n-1),slit_desp(sup)])
                  slit_desp(n-1:sup) = coeff(0)+coeff(1)*x(n-1:sup)
                  spike = 0
                  der_cum = 0.
                  der_tot = 0.
                  count = 0
                  spikes = spikes+1
               endif
            endif
            if spike eq 1 and n eq 0 then slit_desp(0:sup-1) = reverse(slit_desp(sup)-total(reverse(cube_box_der(1:sup,s,l)),/cumulative) ) 

            if spike eq 1 then begin
               count=count+1
               if n ne 0 then begin
               if count gt nmax and abs(der(n-1)) lt ns*sigmas(n-1) then begin 
                 der_cum = 0.
                 der_tot = 0.
                 spike = 0
                 count = 0
                 n = sup
               endif
               endif
            endif
          endfor
        endif  
             
       
       cube_desp(*,s,l) = slit_desp
       

       if spikes gt n_max_spikes then begin
          cube_desp(*,s,l) = cube(*,s,l)
       endif

     endfor
   endfor
 

  ;write the despiked cube
  ;ENVI_WRITE_ENVI_FILE,cube_desp,wl=wave,interleave=2,out_dt=4,offset=0,byte_order=0,/compression,/no_open,out_name=file+'_desp.dat'


endfor 
   
end
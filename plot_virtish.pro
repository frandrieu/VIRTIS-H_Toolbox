function plot_virtish, spect, s_merge=s_merge, b_merge=b_merge,order=order,parity=parity,no_high_ir=no_high_ir,$
  _extra=extra, savegraphic, filename, xmin2=xmin2,iof=iof, bad_bands=bad_bands

  ; PURPOSE
  ;   Plot separate H orders against wavelengths using graphic window, for only one spectrum
  ;   Not adapted for VIRTIS M data
  ;
  ; CALLING SEQUENCE:
  ;   plot=plot_vistish(spectrum)
  ;   To use directly on VIRTIS H calibrated data : plot=plot_virtish(CUBE.qube[*,acquisition number])
  ;   To use directly on VIRTIS H raw data : plot=plot_virtish(CUBE.qube[*,pile number,acquisition number])
  ;
  ; INPUTS:
  ;   Spectrum : a H spectrum : array(3456)
  ;   
  ;
  ; OUTPUTS:
  ;   provide the plot object in order to edit it
  ;
  ; KEYWORDS:
  ;  ORDER: Plots a single order (0 = long wavelengths to 7 = short wavelengths)
  ;  OVER: superposes to current plot if set
  ;  PARITY: if not 0, plot only odd or even channels (choose between 1 or 2)
  ;  NODATA: Explicitely inhibits data plotting
  ;  SAVEsave : allow to save the graph
  ;  FILENAME : if save keyword set then filename need to be defined in order to know where save the file
  ;  S_MERGE : Stéphane Erard's channel list with merging of order
  ;  B_MERGE : Batiste Rousseau's  channel list with merging of order
  ;  NO_HIGH_IR : cut the plot at 3.5µm max
  ;  xmin2 : allow to fix the wavelength range axe at 2µm
  ;  bad_bands : allow not to display bad bands in the plot. bad_band is a n elements array containing the indexes of bad bands, where n is the number f bad bands
  ;
  ; EXAMPLE:
  ;
  ; COMMENTS:

  ; ROUTINES USED:
  ;  v_lamh.pro : gives the wavelength of VIRTIS ROSETTA, Stéphane Erard program
  ;  merge_cube.pro : Batiste Rousseau program giving the channel, lambda and index for normal, even, odd, no_high_ir cases
  ;
  ; HISTORY:
  ;   01/16: Francois Andrieu. writting. Immensely inspired from B. Rousseau's plot_h 
  ;   01/16: FA. Adding bad_bands keyword to allow not displaying a selection of channels
 
  On_error,2

 
  spectrum=spect
  wavelh = v_lamh(/ros) ; dim 432,8
  wave = reform(wavelh,3456) ; dim 3456
  merge = merge_cube() ; tools for filtering or to have lambda and channel from Stéphane or me
  
  
  if keyword_set(bad_bands) then  spectrum[bad_bands]=!Values.F_NAN ;setting to NaN values in the bad bands

 

  if (parity ne !null) then begin ; case when parity is set to 0 by mistake. We add 2 at parity=0 because this case (parity=0) corresponds to a not keyword_set
    if parity eq 0 then begin
      print, 'If parity is set then it must be equal to 1 or 2 (mod 2)'
      print,strcompress('Parity was ='+string(parity)+' now equal to '+string(parity+2))
      parity=parity+2
    endif
  endif


  ;CAS CLASSIQUE (pas de merge)
  if ~keyword_set(s_merge) and ~keyword_set(b_merge) then begin ; classic case (it means 3456 wavelength at the beginning)
    if ~keyword_set(parity) then begin ; with IR and no_high_ir cases are treated in the same way
      lam = MERGE.CLASSIC_TOOLS.LAM_REF ; dim 3456 ; give the lambda to use, it correspond to the classical ones
      spectrum = reform(spectrum(MERGE.CLASSIC_TOOLS.CHANNEL)) ; spectrum of3456 channel
    endif
    if keyword_set(parity) then begin
      if parity mod 2 eq 1 then begin
        wave(MERGE.CLASSIC_TOOLS.ODD_INDEX) = 'NaN' ; put to NaN the odd channel
        wavelh = reform(wave,432,8)
        spectrum(MERGE.CLASSIC_TOOLS.ODD_INDEX) = 'NaN' ; put to NaN the odd channel
      endif
      if parity mod 2 eq 0 then begin
        wave(MERGE.CLASSIC_TOOLS.EVEN_INDEX) = 'NaN' ; put to NaN the even channel
        wavelh = reform(wave,432,8)
        spectrum = reform(spectrum(*))
        spectrum=reform(spectrum,432,8) ; first reform
        last_cube=spectrum(0,*) ; in this case to do the plot we need a start value of the vector of spectrum variable non equal to 0. So we avoid the NaN value
        spectrum=reform(spectrum,3456) ; second reform
        spectrum(MERGE.CLASSIC_TOOLS.EVEN_INDEX) = 'NaN' ; put to NaN the even channel
        spectrum(0)=last_cube(0) ; avoid NaN value for the first element in order to allow plot function to find a meaning to the life...at least
      endif
    endif
  endif

  if keyword_set(s_merge) then begin ; Stéphane channel cases ; these channel come from the list of v_ploth
    if ~keyword_set(parity) and ~keyword_set(no_high_ir) then begin ; case of no parity and no high IR
      lam = MERGE.S_TOOLS.S_LAMBDA ; dim 1739 ; give the lambda to use
      spectrum = reform(spectrum(MERGE.S_TOOLS.S_CHANNEL)) ; reform the cube to use with the good channel selected
    endif
    if ~keyword_set(parity) and keyword_set(no_high_ir) then begin ; case with no parity and high ir
      lam = MERGE.S_TOOLS.S_LAMBDA_NO_HIGH_IR ; dim 1041
      spectrum = reform(spectrum(MERGE.S_TOOLS.S_CHANNEL_NO_HIGH_IR))
    endif
    if keyword_set(parity) and ~keyword_set(no_high_ir) then begin ; case with parity but no high IR
      if parity mod 2 eq 1 then begin
        lam = MERGE.S_TOOLS.S_ODD_LAMBDA ; dim 870
        spectrum = reform(spectrum(MERGE.S_TOOLS.S_ODD_CHANNEL))
      endif
      if parity mod 2 eq 0 then begin
        lam = MERGE.S_TOOLS.S_EVEN_LAMBDA ; dim 869
        spectrum = reform(spectrum(MERGE.S_TOOLS.S_EVEN_CHANNEL))
      endif
    endif
    if keyword_set(parity) and keyword_set(no_high_ir) then begin
      if parity mod 2 eq 1 then begin
        lam = MERGE.S_TOOLS.S_ODD_LAMBDA_NO_HIGH_IR ; dim 521
        spectrum = reform(spectrum(MERGE.S_TOOLS.S_ODD_CHANNEL_NO_HIGH_IR))
      endif
      if parity mod 2 eq 0 then begin
        lam = MERGE.S_TOOLS.S_EVEN_LAMBDA_NO_HIGH_IR ; dim 520
        spectrum = reform(spectrum(MERGE.S_TOOLS.S_EVEN_CHANNEL_NO_HIGH_IR))
      endif
    endif
    order0 = where((lam le 5.03180) AND (lam ge 4.09920),/null) ; define the order of Stéphane
    order1 = where((lam le 4.09830) AND (lam ge 3.49920),/null)
    order2 = where((lam le 3.49780) AND (lam ge 3.08870),/null)
    order3 = where((lam le 3.08820) AND (lam ge 2.82200),/null)
    order4 = where((lam le 2.82120) AND (lam ge 2.50880),/null)
    order5 = where((lam le 2.50840) AND (lam ge 2.28000),/null)
    order6 = where((lam le 2.27960) AND (lam ge 2.08910),/null)
    order7 = where((lam le 2.08890) AND (lam ge 1.92020),/null)
  endif

  if keyword_set(b_merge) then begin ; my list of channel coming from a view of every averaged standard deviation on the entire dataset from MTP006 to MTP017
    ; the principle is exactly the same as previous case so no comments are added
    if ~keyword_set(parity) and ~keyword_set(no_high_ir) then begin
      lam = MERGE.B_TOOLS.MY_LAMBDA ; dim 1646
      spectrum = reform(spectrum(MERGE.B_TOOLS.MY_CHANNEL))
    endif
    if ~keyword_set(parity) and keyword_set(no_high_ir) then begin
      lam = MERGE.B_TOOLS.MY_LAMBDA_NO_HIGH_IR ; dim 947
      spectrum = reform(spectrum(MERGE.B_TOOLS.MY_CHANNEL_NO_HIGH_IR))
    endif
    if keyword_set(parity) and ~keyword_set(no_high_ir) then begin
      if parity mod 2 eq 1 then begin
        lam = MERGE.B_TOOLS.MY_ODD_LAMBDA ; dim 817
        spectrum = reform(spectrum(MERGE.B_TOOLS.MY_ODD_CHANNEL))
      endif
      if parity mod 2 eq 0 then begin
        lam = MERGE.B_TOOLS.MY_EVEN_LAMBDA ; dim 829
        spectrum = reform(spectrum(MERGE.B_TOOLS.MY_EVEN_CHANNEL))
      endif
    endif
    if keyword_set(parity) and keyword_set(no_high_ir) then begin
      if parity mod 2 eq 1 then begin
        lam = MERGE.B_TOOLS.MY_ODD_LAMBDA_NO_HIGH_IR ; dim 467
        spectrum = reform(spectrum(MERGE.B_TOOLS.MY_ODD_CHANNEL_NO_HIGH_IR))
      endif
      if parity mod 2 eq 0 then begin
        lam = MERGE.B_TOOLS.MY_EVEN_LAMBDA_NO_HIGH_IR ; dim 480
        spectrum = reform(spectrum(MERGE.B_TOOLS.MY_EVEN_INDEX_NO_HIGH_IR))
      endif
    endif
    order0 = where((lam le 5.03180) AND (lam ge 4.19850),/null)
    order1 = where((lam le 4.19790) AND (lam ge 3.60060),/null)
    order2 = where((lam le 3.60030) AND (lam ge 3.20110),/null)
    order3 = where((lam le 3.20010) AND (lam ge 2.80160),/null)
    order4 = where((lam le 2.80010) AND (lam ge 2.50040),/null)
    order5 = where((lam le 2.50080) AND (lam ge 2.40130),/null)
    order6 = where((lam le 2.40050) AND (lam ge 2.20120),/null)
    order7 = where((lam le 2.20060) AND (lam ge 1.87120),/null)
  endif



  Tcol= [ [0,168,0],[0,255,84],[0,255,168],[0,255,255],[0,0,255],[128,0,255],[255,0,180],[255,0,128] ] ; color vector
  ;Tcol= [ [0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0] ] ; black color vector
  ;Tcol= [ [255,0,0],[255,0,0],[255,0,0],[255,0,0],[255,0,0],[255,0,0],[255,0,0],[255,0,0] ] ; red color vector

  xtitle = 'wavelength (µm)'


  if order eq !null then begin
    if keyword_set(xmin2) then xmin = 2.0 else xmin = 1.87120 ; put the minimum range in x manually
    if ~keyword_set(S_merge) AND ~keyword_set(B_merge) then begin
      if ~keyword_set(no_high_ir) then xmax = 5.03180 else xmax = 3.5 ; depending of what we look we put a different max value for the x axis
      lam_index = where(reform(wavelh) ge 2.0) ; in order to find the min and max for the y range
      yminmax = minmax(spectrum(lam_index,*))
      if ~keyword_set(parity) then begin ; no parity cases
        spectrum=reform(spectrum,432,8)
        graph=plot(wavelh,spectrum,/nodata,xr=[xmin,xmax],yr=[yminmax(0),yminmax(1)],xtitle=xtitle,_extra=extra, $
          background_color='black',xcolor='white',ycolor='white',xtext_color='0',ytext_color='0',font_color='white',$
          font_style=1,font_size=20,xthick=2,ythick=2,dimensions=[1000,600])
        graph.refresh,/disable ; we avoid intermediate step, .refresh is needed to see the graph at the end
        for i=0,7 do graph=plot(wavelh(*,i),spectrum(*,i),/over,color=Tcol(*,i)) ; plot successive graph on the already openned graphic window
        ;for i=0,7 do graph=scatterplot(wavelh(*,i),spectrum(*,i),/over,color=Tcol(*,i), sym_size=1) ; plot successive graph on the already openned graphic window
        
      endif else begin ; parity cases, just one difference => we have to do a scatterplot because plot function doesn't work correctly... There is the value but they are not visible (anyway the color which choose)
        spectrum=reform(spectrum,432,8)
        graph=plot(wavelh,spectrum,/nodata,xr=[xmin,xmax],yr=[yminmax(0),yminmax(1)],xtitle=xtitle,_extra=extra, $
          background_color='black',xcolor='white',ycolor='white',xtext_color='0',ytext_color='0',font_color='white',$
          font_style=1,font_size=20,xthick=2,ythick=2,dimensions=[1000,600])
        graph.refresh,/disable
        ;for i=0,7 do graph=scatterplot(wavelh(*,i),spectrum(*,i),/over,sym_color=Tcol(*,i),sym_size=1) ; be carefull it's a scatterplot !
        if parity eq 1 then $
          for i=0,7 do graph=plot(wavelh(0:*:2,i),spectrum(0:*:2,i),/over,color=Tcol(*,i)) ; plot successive graph on the already openned graphic window
        if parity eq 2 then $
          for i=0,7 do graph=plot(wavelh(1:*:2,i),spectrum(1:*:2,i),/over,color=Tcol(*,i)) ; plot successive graph on the already openned graphic window



      endelse
    endif

    if keyword_set(S_merge) OR keyword_set(B_merge) then begin ; cases of Stéphane or me channel
      lam_index = where(reform(lam) ge 2.0) ; in order to find the min and max for the y range
      yminmax = minmax(spectrum(lam_index,*))
      if ~keyword_set(no_high_ir) then begin
        xmax = 5.03180 ; put manually the border
        order_list = list(order0,order1,order2,order3,order4,order5,order6,order7) ; we creater the list of order by this way. In a list object you can put everything, anyway there type (vectore, structure, array...)
        graph=plot(lam(order0),spectrum(order0),/nodata,xr=[xmin,xmax],yr=[yminmax(0),yminmax(1)],xtitle=xtitle,_extra=extra, $
          background_color='black',xcolor='white',ycolor='white',xtext_color='0',ytext_color='0',font_color='white',$
          font_style=1,font_size=20,xthick=2,ythick=2,dimensions=[1000,600])
        graph.refresh,/disable
        for i=0,n_elements(order_list)-1 do graph=plot(lam(order_list(i)),spectrum(order_list(i)),/over,color=tcol(*,i)) ; we access at the good order by calling it with the i increment in this list
      endif else begin ; same thing but for no_high_ir case, no big difference but you have to keep them !
        xmax = 3.5
        order_list = list(order2,order3,order4,order5,order6,order7) ; the list is shorter by 2 orders.
        graph=plot(lam(order2),spectrum(order2),/nodata,xr=[xmin,xmax],yr=[yminmax(0),yminmax(1)],xtitle=xtitle,_extra=extra, $
          background_color='black',xcolor='white',ycolor='white',xtext_color='0',ytext_color='0',font_color='white',$
          font_style=1,font_size=20,xthick=2,ythick=2,dimensions=[1000,600])
        graph.refresh,/disable
        for i=0,n_elements(order_list)-1 do graph=plot(lam(order_list(i)),spectrum(order_list(i)),/over,color=tcol(*,i+2)) ; here the index of beginning of the color is +2 added.
      endelse
    endif
    graph.refresh

  endif else begin ; ORDER CASES
    ; here we have the possibility to choose only one order by the keyword order. it allow you to have a graph of this order and only this one
    if ~keyword_set(S_merge) AND ~keyword_set(B_merge) then begin
      xmin = wavelh(-1,order)
      xmax = wavelh(0,order)
      if finite(xmax) eq 0 then xmax=wavelh(1,order) ; need to check if is a 'NaN' value or not, if yes we put the mini at the first value which is not a NaN
      if finite(xmin) eq 0 then xmin=wavelh(-2,order) ; same thing for the minimum
      if ~keyword_set(parity) then begin ; for the parity cases it's a little bit complicated because we have to duplicate the plot initiation, I don't know but anyway
        spectrum=reform(spectrum,432,8)
        graph=plot(wavelh(*,order),spectrum(*,order),xr=[xmin,xmax],xtitle=xtitle,_extra=extra, $
          background_color='black',xcolor='white',ycolor='white',xtext_color='0',ytext_color='0',font_color='white',$
          font_style=1,font_size=20,xthick=2,ythick=2,dimensions=[1000,600],/nodata)
        graph=plot(wavelh(*,order),spectrum(*,order),color=Tcol(*,order),title=strcompress('Order '+string(order)),font_color='white',_extra=extra, $
          font_style=1,font_size=20,xthick=2,ythick=2,/over) ; don't know what two step is required but it works like that
      endif else begin
        spectrum=reform(spectrum,432,8)
        if parity mod 2 eq 0 then spectrum(0,*)=last_cube(0,*)
        graph=plot(wavelh(*,order),spectrum(*,order),xr=[xmin,xmax],_extra=extra, $
          background_color='black',xcolor='white',ycolor='white',xtext_color='0',ytext_color='0',font_color='white',$
          font_style=1,font_size=20,xthick=2,ythick=2,dimensions=[1000,600],/nodata)
        graph=scatterplot(wavelh(*,order),spectrum(*,order),_extra=extra,$
          sym_color=tcol(*,order),title=strcompress('Order '+string(order)),font_color='white',font_style=1,font_size=20,xthick=2,ythick=2,/over)
      endelse
    endif else begin

      order_list = list(order0,order1,order2,order3,order4,order5,order6,order7) ; for the no parity case we have just a list as previously
      xmin = lam((order_list(order))(-1))
      xmax = lam((order_list(order))(0))
      graph=plot(lam(order_list(order)),spectrum(order_list(order)),xr=[xmin,xmax],xtitle=xtitle,_extra=extra, $
        background_color='black',xcolor='white',ycolor='white',xtext_color='0',ytext_color='0',font_color='white',$
        font_style=1,font_size=20,xthick=2,ythick=2,dimensions=[1000,600],/nodata)
      graph=plot(lam(order_list(order)),spectrum(order_list(order)),title=strcompress('Order '+string(order)),font_color='white',_extra=extra, $
        font_style=1,font_size=20,xthick=2,ythick=2,color=tcol(*,order),/over)
    endelse
  endelse


  ; here you can save the plot. save and filename keyword are required.
  if keyword_set(savegraphic) then begin
    if filename eq !null then read,filename,prompt='Define a path/save name for the file :'
    graph.save,filename,width=1920,height=1080,resolution=600
  endif


  return,graph

END
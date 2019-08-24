pro plot_XY_raster_VirtisH_auto, RASTER_NUMBER

  nopositive=0
  wavelength=2.0364 ;2.3164 ;2.0364
  order=6
  
  
  scatplot=1
  dyn_clip=5 ; (%) percentage of the image distribution to clip
  display_clip=1 ; 0: do not display values lower/larger than the colorbar min/max
  ; 1 (anything but 0): display values lower/larger than the colorbar min/max
  ;                     the color correspoundig to min/max

  ;RASTER_NUMBER='00397687865' ; number of the T1 file. Ex: '00405179055' for file 'ESCORT/MTP022/STP080/CALIBRATED/T1_00405179055.CAL'

  DIRMAP='/Users/fandrieu/data/GEOXY/ICMS_files'
  DIRDATA='/Users/fandrieu/data/mapVH'
  DIRPLOT='/Users/fandrieu/Documents/Programmes/IDL_sav_files/Plots/RASTERS/Wave2'
  restore,'/Users/fandrieu/data/raster_S_list_num.sav'
  restore,'/Users/fandrieu/data/raster_T_list_num.sav'
  restore,'/Users/fandrieu/Documents/Programmes/IDL_sav_files/VIRTIS-H_waves.sav'
  restore,'/Users/fandrieu/Documents/Programmes/IDL_sav_files/VIRTIS-H_orders.sav'
  posi=where(raster_T_list_num eq RASTER_NUMBER)
  pw=where(abs(wavelengths-wavelength) lt 0.0016 and orders eq order, /null)
  if (n_elements(pw) eq 0) then begin
    print, wavelength, ': wavelength not found'
    return
  endif
  posw=pw[fix( (n_elements(pw) )/2) ]
  if (posi eq -1) then begin
    print, 'CUBE NOT FOUND for number' + raster_number
    RETURN
  endif

  num_t=raster_T_list_num[posi[0]]
  num_s=raster_S_list_num[posi[0]]

  ; ct = COLORTABLE(72, /reverse)

  restore, '/Users/fandrieu/Documents/Programmes/IDL_sav_files/CT_custom.sav'

  flag=0
  if (RASTER_NUMBER eq '00397099149' or $
    RASTER_NUMBER eq '00397703949' or $
    RASTER_NUMBER eq '00399735912' or $
    RASTER_NUMBER eq '00401096215' or $
    RASTER_NUMBER eq '00401112197' or $
    RASTER_NUMBER eq '00401876264' or $
    RASTER_NUMBER eq '00402836554' or $
    RASTER_NUMBER eq '00405329387' or $
    RASTER_NUMBER eq '00405345373') then flag=1
    
  if (scatplot eq 1) then flag=1
  ;;;;;;;;;;;;;;;;;
  ;67P/
  ;;;;;;;;;;;;;;;;;

  ;num_t='00396861799'
  ;num_s='00396861532'

  ;  num_t='00397119644'
  ;  num_s='00397119377'

  ;num_t='00399735912'
  ;num_s='00399735429'

  ;num_t='00402415913'
  ;num_s='00402415646'

  ;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;



  map_geom=strcompress(DIRMAP+'/XY_Cedric_T1_'+num_t+'.sav', /remove_all)

  restore,map_geom ;,/ver

  ratio=(max(tab_y)-min(tab_y))/(max(tab_x)-min(tab_x))

  cube_name=strcompress(DIRDATA+'/T1_'+num_t+'.QUB', /remove_all)
  cube_name_dark_cal=strcompress(DIRDATA+'/T1_'+num_t+'.DRK', /remove_all)
  cube_name_dark=strcompress(DIRDATA+'/S1_'+num_s+'.QUB', /remove_all)
  cube_name_cal=strcompress(DIRDATA+'/T1_'+num_t+'.CAL', /remove_all)


  cube_raw = virtispds(cube_name, /silent)
  cube_cal = virtispds(cube_name_cal, /silent)
  cube_cal_dark = virtispds(cube_name_dark_cal, /silent)
  cube_raw_dark = virtispds(cube_name_dark, /silent)
  dark=fltarr(cube_raw_dark.QUBE_DIM[0],cube_raw_dark.QUBE_DIM[2])
  dark[*,*]=cube_raw_dark.qube[*,0,*]
  cube_dark=congrid(dark,cube_raw_dark.QUBE_DIM[0],cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2]);,/interp); cubic=-0.5)
  cube_data=fltarr(cube_raw_dark.QUBE_DIM[0],cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2])
  wave1=fltarr(cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2])
  wave1cal=fltarr(cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2])
  wave1dark=fltarr(cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2])
  wave1darkcal=fltarr(cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2])
  wave1_raw_nodark=fltarr(cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2])
  wave1_raw_dark=fltarr(cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2])

  ;  wave2=fltarr(cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2])
  ;  wave2cal=fltarr(cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2])
  ;  wave2dark=fltarr(cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2])
  ;  wave2darkcal=fltarr(cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2])
  ;  wave2_raw_nodark=fltarr(cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2])
  ;  wave2_raw_dark=fltarr(cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2])
  ;
  ;  wave3=fltarr(cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2])
  ;  wave3cal=fltarr(cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2])
  ;  wave3dark=fltarr(cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2])
  ;  wave3darkcal=fltarr(cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2])
  ;  wave3_raw_nodark=fltarr(cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2])
  ;  wave3_raw_dark=fltarr(cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2])

  cube_data=reform(cube_raw.QUBE, cube_raw.QUBE_DIM[0],cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2])

  calibros_interpdknom_s, cube_raw, cube_raw_dark, cube_raw.QUBE_DIM[0], $
    cube_raw.QUBE_DIM[1], cube_raw.QUBE_DIM[2], 0, cube_raw_nodark, dark_raw, scet_raw, /nodark
  ;  calibros_interpdknom_s, cube_raw, cube_raw_dark, cube_raw.QUBE_DIM[0], $
  ;    cube_raw.QUBE_DIM[1], cube_raw.QUBE_DIM[2], 0, cube_rawb, dark_raw, scet_raw


  for i=0,cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2]-1 do  wave1[i]=median([cube_data[posw-5:posw+5,i]])
  for i=0,cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2]-1 do  wave1cal[i]=median([cube_cal.QUBE[posw-5:posw+5,i]])
  ;for i=0,cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2]-1 do  wave1dark[i]=median([cube_dark[posw-5:posw+5,i]])
  for i=0,cube_cal_dark.QUBE_DIM[1]-1 do  wave1darkcal[i]=median([cube_cal_dark.qube[posw-5:posw+5,i]])
  for i=0,cube_cal_dark.QUBE_DIM[1]-1 do  wave1_raw_nodark[i]=median([cube_raw_nodark[posw-5:posw+5,i]])
  ; for i=0,cube_cal_dark.QUBE_DIM[1]-1 do  wave1_raw_dark[i]=median([dark_raw[posw-5:posw+5,i]])



  ;  for i=0,cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2]-1 do  wave2[i]=median([cube_data[2780:2800,i]])
  ;  for i=0,cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2]-1 do  wave2cal[i]=median([cube_cal.QUBE[2790:2800,i]])
  ;  for i=0,cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2]-1 do  wave2dark[i]=median([cube_dark[2790:2800,i]])
  ;  for i=0,cube_cal_dark.QUBE_DIM[1]-1 do  wave2darkcal[i]=median([cube_cal_dark.qube[2790:2800,i]])
  ;  for i=0,cube_cal_dark.QUBE_DIM[1]-1 do  wave2_raw_nodark[i]=median([cube_raw_nodark[2790:2800,i]])
  ;  for i=0,cube_cal_dark.QUBE_DIM[1]-1 do  wave2_raw_dark[i]=median([dark_raw[2790:2800,i]])
  ;
  ;  for i=0,cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2]-1 do  wave3[i]=median([cube_data[2945:2955,i]])
  ;  for i=0,cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2]-1 do  wave3cal[i]=median([cube_cal.QUBE[2945:2955,i]])
  ;  for i=0,cube_raw.QUBE_DIM[1]*cube_raw.QUBE_DIM[2]-1 do  wave3dark[i]=median([cube_dark[2945:2955,i]])
  ;  for i=0,cube_cal_dark.QUBE_DIM[1]-1 do  wave3darkcal[i]=median([cube_cal_dark.qube[2945:2955,i]])
  ;  for i=0,cube_cal_dark.QUBE_DIM[1]-1 do  wave3_raw_nodark[i]=median([cube_raw_nodark[2945:2955,i]])
  ;  for i=0,cube_cal_dark.QUBE_DIM[1]-1 do  wave3_raw_dark[i]=median([dark_raw[2945:2955,i]])


  if (flag eq 1) then begin

    if ( nopositive eq 1) then maxvalue=0.
    wave1cal[where(wave1cal lt 0.)]=-0.1
    minValue = Min(wave1cal)
    maxValue = Max(wave1cal)
    maxvalue=0.15
    wave1cal[where(wave1cal gt maxvalue)]=0.

    clustuve = SCATTERPLOT(tab_x, tab_y, $
      SYMBOL='circle', RGB_TABLE=ct, /SYM_FILLED,$
      XTITLE='Distance (km)', sym_size=0.3,$
      YTITLE = 'Distance (km)', $
      TITLE='T1_'+num_t+'at '+string(cube_cal.table[0,posw])+'$µ m$', $
      MAGNITUDE=wave1cal, POSITION=[0.05,0.20,0.95,0.9], $
      xrange=[min(tab_x),max(tab_x)], yrange=[min(tab_y),max(tab_y)],$
      xstyle=1, ystyle=1)
    cb1 = COLORBAR(TITLE='Calibrated Radiance ($W m^{-2} sr^{-1} /mu ^{-1}$)',TARGET=clustuve, ORIENTATION=0, $
      POSITION=[0.3,0.08,0.7,0.12], range=[minvalue,maxvalue], taper=1, TICKFORMAT='(F5.2)' )

  endif else begin


    n_el=n_elements(wave1cal)
    n_clip=fix(n_el*dyn_clip*0.01)

    wawa=wave1cal
    sowa=sort(wawa)
    mimi=median(wawa[sowa[0:n_clip]])
    mama=median(wawa[sowa[n_el-n_clip:n_el-1]])
    if (display_clip ne 0) then begin
      wawa[where(wawa le mimi)]=mimi
      wawa[where(wawa ge mama)]=mama
    endif
    fullrange=mama-mimi
    mimi=mimi-fullrange*0.01
    mama=mama+fullrange*0.01
    c1 = CONTOUR(wawa, tab_x, tab_y, /FILL, RGB_TABLE=ct, aspect_ratio=ratio, $
      TITLE='T1_'+num_t+' CALIBRATED at '+string(cube_cal.table[0,posw])+'$µ m$' ,$
      POSITION=[0.05,0.18,0.95,0.9], xrange=[min(tab_x),max(tab_x)], yrange=[min(tab_y),max(tab_y)],$
      xstyle=1, ystyle=1, n_levels=25, min_value=mimi, max_value=mama)
    cb1 = COLORBAR(TITLE='Calibrated Radiance ($W m^{-2} sr^{-1} µ ^{-1}$)',TARGET=c1, ORIENTATION=0, $
      POSITION=[0.3,0.08,0.7,0.12], taper=1, TICKFORMAT='(F5.2)')

    plotname=strcompress(dirplot+'/T1_'+num_t+'_CALIBRATED_'+'at_'+string(cube_cal.table[0,posw])+'.png', /remove_all)
    c1.Save, plotname, BORDER=10, RESOLUTION=300, /TRANSPARENT


    wawa=wave1darkcal
    sowa=sort(wawa)
    mimi=median(wawa[sowa[0:n_clip]])
    mama=median(wawa[sowa[n_el-n_clip:n_el-1]])
    if (display_clip ne 0) then begin
      wawa[where(wawa le mimi)]=mimi
      wawa[where(wawa ge mama)]=mama
    endif
    fullrange=mama-mimi
    mimi=mimi-fullrange*0.01
    mama=mama+fullrange*0.01
    c2 = CONTOUR(wawa, tab_x, tab_y, /FILL, RGB_TABLE=ct, aspect_ratio=ratio,$
      TITLE='T1_'+num_t+' DARKS '+'at '+string(cube_cal.table[0,posw])+'$µ m$',$
      POSITION=[0.05,0.18,0.95,0.9], xrange=[min(tab_x),max(tab_x)], yrange=[min(tab_y),max(tab_y)],$
      xstyle=1, ystyle=1, n_levels=25, min_value=mimi, max_value=mama)
    cb2 = COLORBAR(TITLE='Estimated dark value',TARGET=c2, ORIENTATION=0, $
      POSITION=[0.1,0.08,0.9,0.12], taper=1, TICKFORMAT='(F5.0)')

    plotname=strcompress(dirplot+'/T1_'+num_t+'_DARKS_'+'at_'+string(cube_cal.table[0,posw])+'.png', /remove_all)
    c2.Save, plotname, BORDER=10, RESOLUTION=300, /TRANSPARENT
    ;      wawa=wave1
    ;      sowa=sort(wawa)
    ;      mimi=median(wawa[sowa[0:n_clip]])
    ;      mama=median(wawa[sowa[n_el-n_clip:n_el-1]])
    ;      if (display_clip ne 0) then begin
    ;        wawa[where(wawa le mimi)]=mimi
    ;        wawa[where(wawa ge mama)]=mama
    ;      endif
    ;      fullrange=mama-mimi
    ;      mimi=mimi-fullrange*0.01
    ;      mama=mama+fullrange*0.01
    ;      c2b = CONTOUR(wawa, tab_x, tab_y, /FILL, RGB_TABLE=ct, aspect_ratio=ratio,$
    ;        TITLE='T1_'+num_t+' RAW DATA '+'at '+string(cube_cal.table[0,posw])+'$µ m$',$
    ;        POSITION=[0.05,0.18,0.95,0.9], xrange=[min(tab_x),max(tab_x)], yrange=[min(tab_y),max(tab_y)],$
    ;        xstyle=1, ystyle=1, n_levels=25, min_value=mimi, max_value=mama)
    ;      cb2b = COLORBAR(TITLE='Raw data',TARGET=c2b, ORIENTATION=0, $
    ;        POSITION=[0.1,0.08,0.9,0.12], taper=1, TICKFORMAT='(F5.1)')


    wawa=wave1_raw_nodark
    sowa=sort(wawa)
    mimi=median(wawa[sowa[0:n_clip]])
    mama=median(wawa[sowa[n_el-n_clip:n_el-1]])
    if (display_clip ne 0) then begin
      wawa[where(wawa le mimi)]=mimi
      wawa[where(wawa ge mama)]=mama
    endif
    fullrange=mama-mimi
    mimi=mimi-fullrange*0.01
    mama=mama+fullrange*0.01
    c2b = CONTOUR(wawa, tab_x, tab_y, /FILL, RGB_TABLE=ct, aspect_ratio=ratio,$
      TITLE='T1_'+num_t+' RAW DATA + DARKS '+'at '+string(cube_cal.table[0,posw])+'$µ m$',$
      POSITION=[0.05,0.18,0.95,0.9], xrange=[min(tab_x),max(tab_x)], yrange=[min(tab_y),max(tab_y)],$
      xstyle=1, ystyle=1, n_levels=25, min_value=mimi, max_value=mama)
    cb2b = COLORBAR(TITLE='Raw data + dark (real signal)',TARGET=c2b, ORIENTATION=0, $
      POSITION=[0.1,0.08,0.9,0.12], taper=1, TICKFORMAT='(F6.1)')

    plotname=strcompress(dirplot+'/T1_'+num_t+'_NODARKS_'+'at_'+string(cube_cal.table[0,posw])+'.png', /remove_all)
    c2b.Save, plotname, BORDER=10, RESOLUTION=300, /TRANSPARENT



    ;      wawa=wave1_raw_dark
    ;      sowa=sort(wawa)
    ;      mimi=median(wawa[sowa[0:n_clip]])
    ;      mama=median(wawa[sowa[n_el-n_clip:n_el-1]])
    ;      mi=mimi
    ;      ma=mama
    ;      if (display_clip ne 0) then begin
    ;        wawa[where(wawa le mimi)]=mimi
    ;        wawa[where(wawa ge mama)]=mama
    ;      endif
    ;      fullrange=mama-mimi
    ;      mimi=mimi-fullrange*0.01
    ;      mama=mama+fullrange*0.01
    ;      c2c = CONTOUR(wawa, tab_x, tab_y, /FILL, RGB_TABLE=ct, aspect_ratio=ratio,$
    ;        TITLE='T1_'+num_t+' RAW DARKS '+'at '+string(cube_cal.table[0,posw])+'$µ m$',$
    ;        POSITION=[0.05,0.18,0.95,0.9], xrange=[min(tab_x),max(tab_x)], yrange=[min(tab_y),max(tab_y)],$
    ;        xstyle=1, ystyle=1, n_levels=25, min_value=mimi, max_value=mama)
    ;      cb2c = COLORBAR(TITLE='dark value',TARGET=c2c, ORIENTATION=0, $
    ;        POSITION=[0.1,0.08,0.9,0.12], taper=1, TICKFORMAT='(F5.0)')

  
  endelse
windowdeleteall
end

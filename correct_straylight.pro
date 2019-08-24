pro correct_straylight, cube_name, cube_corrected
  
  opt=1
  
  cubedate=long64(strmid(cube_name, 14,11, /reverse_offset))
  restore, '/Users/fandrieu/Documents/Programmes/IDL_sav_files/list_straylight_robust_models_fullpath.sav'
  straylight_model_names=list_straylight_robust_models
;  straylight_model_names=[00396877876,00397687865,00397703949,00398655773,00398676589,00399297801,00400361236,$
;    00400821248,00400836942,00400857434,00401096215,00401112197,00402358355,00402379141,00402395126,00402415913,$
;    00402836554,00405345373]

;  straylight_model_names=[00397687865,00397703949,00398655773,00398676589,$
;    00399297801,00399318584,00400361236,00400821248,00400836942,00400857434,$
;    00401096215,00401112197,00404099849,00404320557,00405345373,00405366158]
  
;  straylight_model_names=[00396861799,00396877876,00396898661,00397099149,00397119644,00397687865,$
;    00397703949,00398655773,00398676589,00399297801,00399318584,00399735912,$
;    00400361236,00400821248,00400836942,00400857434,00401096215,00401112197,$
;    00401876264,00401885872,00401901567,00402358355,00402379141,00402395126,$
;    00402415913,00402526986,00402542681,00402836554,00403700700,00403716395,$
;    00404099849,00404304862,00404320557,00404341053,00404982257,00404999751,$
;    00405018446,00405034141,00405308601,00405329387,00405345373,00405366158]
basename='/Users/fandrieu/Documents/Programmes/IDL_sav_files/straylight_spectrum_model_'
  straylight_model_chosen=where(straylight_model_names-cubedate eq min(straylight_model_names-cubedate))
  endname=string(straylight_model_names[straylight_model_chosen[0]], format='(I011)')
  straylight_spectrum_name=strcompress(basename+endname+'.sav', /remove_all)
  restore, straylight_spectrum_name
  
  ;restore, '/Users/fandrieu/Documents/Programmes/IDL_sav_files/straylight_spectrum_model_nom.sav'
  restore,'/Users/fandrieu/Documents/Programmes/IDL_sav_files/VIRTIS-H_waves.sav'
  restore,'/Users/fandrieu/Documents/Programmes/IDL_sav_files/VIRTIS-H_orders.sav'
  ;dif_straylight=0.229203; result of: dif_straylight=median(straylight_spectrum_model[pos3r:pos3l:2, *], $
  ;  dimension=1)-median(straylight_spectrum_model[pos4r:pos4l:2, *], dimension=1)
  ;  
  ; where straylight_spectrum_model is an empirical model for the straylight, 
  ; estimated using all available backup cubes.

  
  cube=virtispds(cube_name,/si)
  data=cube.qube
  ;;;Scaling of the function around 2.75µm using difference between orders 3 and 4
  if opt eq 0 then begin  
    pos=intarr(4,7)
    pos[0,0]=396 ; lambda=4.15090µm (order 0, even, affected by stray light)
    pos[1,0]=360 ; lambda=4.25040µm (order 0, even, affected by stray light)
    pos[2,0]=542 ; lambda=4.14900µm (order 1, even, NOT affected by stray light)
    pos[3,0]=480 ; lambda=4.25120µm (order 1, even, NOT affected by stray light)
  
    pos[0,1]=854 ; lambda=3.49920µm (order 1, even, affected by stray light)
    pos[1,1]=832 ; lambda=3.55290µm (order 1, even, affected by stray light)
    pos[2,1]=1056 ; lambda=3.50110µm (order 2, even, NOT affected by stray light)
    pos[3,1]=1026 ; lambda=3.54940µm (order 2, even, NOT affected by stray light)
    
    pos[0,2]=1282 ; lambda=3.07160µm (order 2, even, affected by stray light)
    pos[1,2]=1268 ; lambda=3.10150µm (order 2, even, affected by stray light)
    pos[2,2]=1518 ; lambda=3.06850µm (order 3, even, NOT affected by stray light)
    pos[3,2]=1498 ; lambda=3.09870µm (order 3, even, NOT affected by stray light)
  
    pos[0,3]=1702 ; lambda=2.75220µm (order 3, even, affected by stray light)
    pos[1,3]=1676 ; lambda=2.80160µm (order 3, even, affected by stray light)
    pos[2,3]=1956 ; lambda=2.75340µm (order 4, even, NOT affected by stray light)
    pos[3,3]=1922 ; lambda=2.80160µm (order 4, even, NOT affected by stray light)
  
    pos[0,4]=2120 ; lambda=2.50040µm (order 4, even, affected by stray light)
    pos[1,4]=2090 ; lambda=2.55030µm (order 4, even, affected by stray light)
    pos[2,4]=2390 ; lambda=2.49950µm (order 5, even, NOT affected by stray light)
    pos[3,4]=2350 ; lambda=2.54910µm (order 5, even, NOT affected by stray light)
    
    pos[0,5]=2540 ; lambda=2.29070µm (order 5, even, affected by stray light)
    pos[1,5]=2508 ; lambda=2.33850µm (order 5, even, affected by stray light)
    pos[2,5]=2822 ; lambda=2.29120µm (order 6, even, NOT affected by stray light)
    pos[3,5]=2778 ; lambda=2.34090µm (order 6, even, NOT affected by stray light)
  
    pos[0,6]=2934 ; lambda=2.15140µm (order 6, even, affected by stray light)
    pos[1,6]=2904 ; lambda=2.19090µm (order 6, even, affected by stray light)
    pos[2,6]=3220 ; lambda=2.15130µm (order 7, even, NOT affected by stray light)
    pos[3,6]=3182 ; lambda=2.18980µm (order 7, even, NOT affected by stray light)
    
    
    dif_straylight=fltarr(7)
    index_straylight=fltarr(7, cube.qube_dim[1])
    for order_index=0,6 do begin
      dif_straylight[order_index]=median(straylight_spectrum_model[pos[1,order_index]:pos[0,order_index]:2, *],dimension=1)-$
        median(straylight_spectrum_model[pos[3,order_index]:pos[2,order_index]:2, *], dimension=1)
      index_straylight[order_index,*]=median(data[pos[1,order_index]:pos[0,order_index]:2, *], dimension=1)-$
        median(data[pos[3,order_index]:pos[2,order_index]:2, *], dimension=1)
    endfor

    ;index_straylight=median(data[pos3r:pos3l:2, *], dimension=1)-median(data[pos4r:pos4l:2, *], dimension=1)
    straypos=where(abs(index_straylight[3, *]) gt 0.); stddev(data)^2 )
    data2=fltarr(cube.qube_dim[0], cube.qube_dim[1])
    for aq=0, n_elements(straypos)-1 do begin
      for order_index=0,6 do $
        data[order_index*432:(order_index+1)*432-1,straypos[aq]]=data[order_index*432:(order_index+1)*432-1,straypos[aq]]-$
        straylight_spectrum_model[order_index*432:(order_index+1)*432-1]*index_straylight[order_index,straypos[aq]]/dif_straylight[order_index]
      data[7*432:8*432-1,straypos[aq]]=data[7*432:8*432-1,straypos[aq]]-$
        straylight_spectrum_model[7*432:(order_index+1)*432-1]*index_straylight[6,straypos[aq]]/dif_straylight[6]
    endfor
    cube_corrected=cube
    cube_corrected.qube=data

  endif else begin

    pos=intarr(4,6)
    
    ;***ORDER 2***
    pos[0,0]=1215 
    pos[1,0]=1225 
    pos[2,0]=1280 
    pos[3,0]=1290 
    
    ;***ORDER 3***
    pos[0,1]=1625 
    pos[1,1]=1645 
    pos[2,1]=1700 
    pos[3,1]=1720 
    
    ;***ORDER 4***
    pos[0,2]=2070 
    pos[1,2]=2080 
    pos[2,2]=2140 
    pos[3,2]=2150 
    
    ;***ORDER 5***
    pos[0,3]=2495 
    pos[1,3]=2505 
    pos[2,3]=2555
    pos[3,3]=2565 
    
    ;***ORDER 6***
    pos[0,4]=2945
    pos[1,4]=2955
    pos[2,4]=3005
    pos[3,4]=3015
    
    ;***ORDER 7***
    pos[0,5]=3375
    pos[1,5]=3385
    pos[2,5]=3435 
    pos[3,5]=3445 
    
    
    dif_straylight=fltarr(8)
    index_straylight=fltarr(8, cube.qube_dim[1])
    for order_index=0,5 do begin
      dif_straylight[order_index+2]=median(straylight_spectrum_model[pos[0,order_index]:pos[1,order_index]:2, *],dimension=1)-$
        median(straylight_spectrum_model[pos[2,order_index]:pos[3,order_index]:2, *], dimension=1)
      index_straylight[order_index+2,*]=median(data[pos[0,order_index]:pos[1,order_index]:2, *], dimension=1)-$
        median(data[pos[2,order_index]:pos[3,order_index]:2, *], dimension=1)
    endfor
    dif_straylight[0:1]=dif_straylight[2]
    index_straylight[0,*]=index_straylight[2,*]
    index_straylight[1,*]=index_straylight[2,*]
    
    
    posmis0=[396,360,542,480] ; lambda=4.15090µm (order 0, even, affected by stray light)
                              ; lambda=4.25040µm (order 0, even, affected by stray light)
                              ; lambda=4.14900µm (order 1, even, NOT affected by stray light)
                              ; lambda=4.25120µm (order 1, even, NOT affected by stray light)
    
    posmis2=[1282,1268,1518,1498] ; lambda=3.07160µm (order 2, even, affected by stray light)
                                 ; lambda=3.10150µm (order 2, even, affected by stray light)
                                 ; lambda=3.06850µm (order 3, even, NOT affected by stray light)
                                 ; lambda=3.09870µm (order 3, even, NOT affected by stray light)


   mis_order0=median(data[posmis0[1]:posmis0[0]:2, *], dimension=1)-$
     median(data[posmis0[3]:posmis0[2]:2, *], dimension=1)
   mis_order2=median(data[posmis2[1]:posmis2[0]:2, *], dimension=1)-$
     median(data[posmis2[3]:posmis2[2]:2, *], dimension=1)

;  dif_stray0=median(straylight_spectrum_model[posmis0[1]:posmis0[0]:2, *],dimension=1)-$
;     median(straylight_spectrum_model[posmis0[3]:posmis0[2]:2, *], dimension=1)
;  compare=abs((mis_order0/dif_stray0-index_straylight[0,*]/dif_straylight[0])/(index_straylight[0,*]/dif_straylight[0]))
;  
;  wuwu=where(compare lt 0.2,/NULL)
;    index_straylight[0,wuwu]=(median(data[posmis0[1]:posmis0[0]:2, wuwu], dimension=1)-$
;        median(data[posmis0[3]:posmis0[2]:2, wuwu], dimension=1))*dif_straylight[0]/$
;        (median(straylight_spectrum_model[posmis0[1]:posmis0[0]:2, wuwu],dimension=1)-$
;        median(straylight_spectrum_model[posmis0[3]:posmis0[2]:2, wuwu], dimension=1))



    ;index_straylight=median(data[pos3r:pos3l:2, *], dimension=1)-median(data[pos4r:pos4l:2, *], dimension=1)
    straypos=where(abs(index_straylight[3, *]) gt 0. and abs(index_straylight[5, *]) gt 0. $
      and mis_order0 gt 0.2*stddev(data)^2  and mis_order2 gt 0.2*stddev(data)^2 )
    data2=fltarr(cube.qube_dim[0], cube.qube_dim[1])
    for aq=0, n_elements(straypos)-1 do begin
      for order_index=0,7 do $
        data[order_index*432:(order_index+1)*432-1,straypos[aq]]=data[order_index*432:(order_index+1)*432-1,straypos[aq]]-$
        straylight_spectrum_model[order_index*432:(order_index+1)*432-1]*index_straylight[order_index,straypos[aq]]/dif_straylight[order_index]
    endfor
    cube_corrected=cube
    cube_corrected.qube=data

  endelse

  return

end
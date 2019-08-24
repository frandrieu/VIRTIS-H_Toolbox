function sectrum_straycor, sp, cube_name

  ;
  ; NAME
  ;   SPECTRUM_STRAYCOR
  ;
  ; PURPOSE
  ;   Read a single VIRTIS-H specrum (3456 flaoting array), and correct the contribution
  ;   from the stray light
  ;   if not nominal mode VIRTIS-H calibrated sp, only calls virtispds function
  ;   - For Qubes sp: returns label, sp, suffix and HK list in a structure.
  ;    HK are grouped in elemental structures relative to each acquisition.
  ;    - If not VIRTIS sp, return label + error code !err = -1
  ;
  ; CALLING SEQUENCE:
  ;   result=VIRTISPDS_STRAYCOR_NOMINAL('sp')
  ;
  ; WARNING
  ;   the directory 'maindir' where the empirical stray light models are stored must be manually
  ;   entered befor compilation
  ;
  ; INPUTS:
  ; SP = 3456 floating points array
  ; cube_name: Scalar string containing the name VIRTIS-H cube the SP is from
  ;
  ; OUTPUT:
  ; result: 3456 floating points array
  ;   ;
  ; MODIFICATION HISTORY: Written by François Andrieu, 03/2018 from virtispds_straycor
  ;; Adding 'positive' and 'negative' manifestations of stray light models separately



  On_error, 2                    ;2: Return to user, 0: debug

  maindir='/Users/fandrieu/Documents/Programmes/IDL_sav_files'
  restore, strcompress(maindir+'/VIRTIS-H_overlap025_upward.sav', /remove_all)
  backup=keyword_set(backup)
  ;restore, strcompress(maindir+'/VIRTIS-H_overlap_upward.sav', /remove_all)


  if (strmid(cube_name, 17,2, /reverse_offset)) ne 'T1' then begin
    print, cube_name, ' is not a nominal mode calibrated VIRTIS H cube'
    print, 'NO straylight was removed'
    result=sp
    return, sp
  endif

  cubedate=long64(strmid(cube_name, 14,11, /reverse_offset))

  if (backup eq 0) then begin
    ; Available stray light models
    restore, strcompress(maindir+'/list_straylight_robust_models_pos.sav', /remove_all)
    restore, strcompress(maindir+'/list_straylight_robust_models_neg.sav', /remove_all)
    ;straylight_model_names=list_straylight_robust_models
    straylight_model_names_pos=list_straylight_robust_models
    straylight_model_names_neg=list_straylight_robust_models_neg

    ; Selection of the closest model
    ;basename=maindir+'/straylight_spectrum_model_'
    ;straylight_model_chosen=where(straylight_model_names-cubedate eq min(straylight_model_names-cubedate))
    ;endname=string(straylight_model_names[straylight_model_chosen[0]], format='(I011)')
    basename=maindir+'/straylight_spectrum_model_'
    straylight_model_chosen_pos=where(straylight_model_names_pos-cubedate eq min(straylight_model_names_pos-cubedate))
    endname_pos=string(straylight_model_names_pos[straylight_model_chosen_pos[0]], format='(I011)')
    straylight_model_chosen_neg=where(straylight_model_names_neg-cubedate eq min(straylight_model_names_neg-cubedate))
    endname_neg=string(straylight_model_names_neg[straylight_model_chosen_neg[0]], format='(I011)')

    ;straylight_spectrum_name=strcompress(basename+endname+'.sav', /remove_all)
    straylight_spectrum_pos_name=strcompress(basename+endname_pos+'_pos.sav', /remove_all)
    straylight_spectrum_neg_name=strcompress(basename+endname_neg+'_neg.sav', /remove_all)
  endif else begin
    straylight_spectrum_name=strcompress(maindir+'/straylight_spectrum_model.sav', /remove_all)
  endelse
  ;restore, straylight_spectrum_name
  restore, straylight_spectrum_pos_name
  restore, straylight_spectrum_neg_name


  sp=sp


  ;Positions where stray light can be easily identified on orders 0 to 7
  pos=intarr(4,8)
  ;***ORDER 0***
  pos[0,0]=230
  pos[1,0]=250
  pos[2,0]=400
  pos[3,0]=420

  ;***ORDER 1***
  pos[0,1]=665
  pos[1,1]=685
  pos[2,1]=830
  pos[3,1]=850

  ;***ORDER 2***
  pos[0,2]=1215
  pos[1,2]=1225
  pos[2,2]=1280
  pos[3,2]=1290

  ;***ORDER 3***
  pos[0,3]=1625
  pos[1,3]=1645
  pos[2,3]=1700
  pos[3,3]=1720

  ;***ORDER 4***
  pos[0,4]=2070
  pos[1,4]=2080
  pos[2,4]=2140
  pos[3,4]=2150

  ;***ORDER 5***
  pos[0,5]=2495
  pos[1,5]=2505
  pos[2,5]=2555
  pos[3,5]=2565

  ;***ORDER 6***
  pos[0,6]=2945
  pos[1,6]=2955
  pos[2,6]=3005
  pos[3,6]=3015

  ;***ORDER 7***
  pos[0,7]=3375
  pos[1,7]=3385
  pos[2,7]=3435
  pos[3,7]=3445


  ; identification of the stray light in the cube
  dif_straylight_pos=fltarr(8)
  dif_straylight_neg=fltarr(8)
  index_straylight=fltarr(8)
  for order_index=0,7 do begin
    dif_straylight_pos[order_index]=-median(straylight_spectrum_model_pos[pos[0,order_index]:pos[1,order_index]:2, *],dimension=1)+$
      median(straylight_spectrum_model_pos[pos[2,order_index]:pos[3,order_index]:2, *], dimension=1)
    index_straylight[order_index]=-median(sp[pos[0,order_index]:pos[1,order_index]:2], dimension=1)+$
      median(sp[pos[2,order_index]:pos[3,order_index]:2], dimension=1)
    dif_straylight_neg[order_index]=-median(straylight_spectrum_model_neg[pos[0,order_index]:pos[1,order_index]:2],dimension=1)+$
      median(straylight_spectrum_model_neg[pos[2,order_index]:pos[3,order_index]:2], dimension=1)
  endfor
  ;  dif_straylight[0:2]=dif_straylight[3]
  ;  index_straylight[0,*]=index_straylight[3,*]
  ;  index_straylight[1,*]=index_straylight[3,*]
  ;  index_straylight[2,*]=index_straylight[3,*]
  ;**********
  ;mismatch between orders 0 and 1 and between orders 2 and 3
  posmis0=[396,360,542,480]     ; lambda=4.15090µm (order 0, even, affected by stray light)
  ; lambda=4.25040µm (order 0, even, affected by stray light)
  ; lambda=4.14900µm (order 1, even, NOT affected by stray light)
  ; lambda=4.25120µm (order 1, even, NOT affected by stray light)
  posmis2=[1282,1256,1522,1488] ; lambda=3.07160µm (order 2, even, affected by stray light)
  ; lambda=3.10150µm (order 2, even, affected by stray light)
  ; lambda=3.06850µm (order 3, even, NOT affected by stray light)
  ; lambda=3.09870µm (order 3, even, NOT affected by stray light)
  posmis3=[1702,1676,1956,1922] ; lambda=2.75220µm (order 3, even, affected by stray light)
  ; lambda=2.80160µm (order 3, even, affected by stray light)
  ; lambda=2.75340µm (order 4, even, NOT affected by stray light)
  ; lambda=2.80160µm (order 4, even, NOT affected by stray light)
  posmis5=[2540,2508,2822,2778] ; lambda=2.29070µm (order 5, even, affected by stray light)
  ; lambda=2.33850µm (order 5, even, affected by stray light)
  ; lambda=2.29120µm (order 6, even, NOT affected by stray light)
  ; lambda=2.34090µm (order 6, even, NOT affected by stray light)
  ;**********
  mis_order0=median(sp[posmis0[1]:posmis0[0]:2, *], dimension=1)-$
    median(sp[posmis0[3]:posmis0[2]:2, *], dimension=1)
  mis_order2=median(sp[posmis2[1]:posmis2[0]:2, *], dimension=1)-$
    median(sp[posmis2[3]:posmis2[2]:2, *], dimension=1)
  ;mis_order3=-median(sp[posmis3[1]:posmis3[0]:2, *], dimension=1)+$
  ;  median(sp[posmis3[3]:posmis3[2]:2, *], dimension=1)
  mis_order5=median(sp[posmis5[1]:posmis5[0]:2, *], dimension=1)-$
    median(sp[posmis5[3]:posmis5[2]:2, *], dimension=1)




  ;Criterion based on both slopes and mismatch between orders : signature of the stray light
  ;  straypos=where(abs(index_straylight[3, *]) gt 0. and abs(index_straylight[5, *]) gt 0. $
  ;    and  abs(mis_order2) gt 1.*stddev(sp[2*432:3*432-1,*])^2); and abs(mis_order5) gt 1.*stddev(sp[*,*])^2)

  ;;;Mismatch
  ;  straypos=where( (mis_order2) gt 1.*stddev(sp[2*432:3*432-1,*])^2 and $
  ;    (mis_order5) gt 0.5*stddev(sp[*,*])^2)
  ;  strayneg=where( (mis_order2) lt -1.*stddev(sp[2*432:3*432-1,*])^2 and $
  ;    (mis_order5) lt -0.5*stddev(sp[*,*])^2)
  ;;;Slope
  ;  straypos=where( (index_straylight[2,*]) gt 1.*stddev(sp[2*432:3*432-1,*])^2 and $
  ;    (index_straylight[5,*]) gt 0.5*stddev(sp[*,*])^2)
  ;  strayneg=where( (index_straylight[2,*]) lt -1.*stddev(sp[2*432:3*432-1,*])^2 and $
  ;    (index_straylight[5,*]) lt -0.5*stddev(sp[*,*])^2)

  ;;Mismatch & slope


  ;;;NOISE ESTIMATION;;;
  w_over0m2=w_over0-2
  w_over0p2=w_over0+2
  w_over2m2=w_over2-2
  w_over2p2=w_over2+2
  noise0=( 1.482602 / sqrt(6)) *median(abs(2.*sp[overlap_waves0[w_over0]] - $
    sp[overlap_waves0[w_over0m2]] - sp[overlap_waves0[w_over0p2]]), dimension=1)
  noise2=( 1.482602 / sqrt(6)) *median(abs(2.*sp[overlap_waves2[w_over2]] - $
    sp[overlap_waves0[w_over2m2]] - sp[overlap_waves0[w_over2p2]]), dimension=1)
  
  ;noise2=stddev(sp[overlap_waves2[w_over2]], dimension=1)
;  noise5=stddev(sp[overlap_waves5[w_over5]], dimension=1)

  ;  straypos=where( (index_straylight[2,*]) gt 0.1*noise2 and (index_straylight[5,*]) gt $
  ;     0.1*noise5 and abs(sp[w_over, *]-sp[overlap_waves[w_over],*]) gt 0.01*noise0, /null)
  ;  strayneg=where( (index_straylight[2,*]) lt -0.1*noise2 and (index_straylight[5,*]) lt $
  ;    -0.1*noise5 and abs(sp[w_over, *]-sp[overlap_waves[w_over],*]) gt 0.01*noise0, /null)
 stray=0.
 if ((index_straylight[5,*]) gt 0.1*noise5 and (index_straylight[2,*]) gt 0.1*noise2 and $
    abs(sp[w_over0, *]-sp[overlap_waves0[w_over0],*]) gt 0.01*noise0) then stray=1.
 if ((index_straylight[5,*]) lt -1.*noise5 and (index_straylight[2,*]) lt -0.1*noise2 and $
    abs(sp[w_over0, *]-sp[overlap_waves0[w_over0],*]) gt 0.01*noise0) then stray=-1.



  coef=fltarr(8)
  

  indneg0=index_straylight[0,straypos]
  indneg1=index_straylight[1,straypos]
  indneg2=index_straylight[2,straypos]
  th0=therm0[strayneg]
  th0neg=where(th0 GT abs(0.5*index_straylight[0,strayneg]) and th0 gt 0.005 , /null) ;signal is greater than 50% of estimated stray light contribution for order 0
  th1=therm1[strayneg]
  th1neg=where(th1 GT abs(0.5*index_straylight[1,strayneg]) and th1 gt 0.005 , /null) ;signal is greater than 50% of estimated stray light contribution for order 0
  th2=therm2[strayneg]
  th2neg=where(th2 GT abs(0.5*index_straylight[2,strayneg]) and th2 gt 0.005 , /null) ;signal is greater than 50% of estimated stray light contribution for order 0
  ;Removal of the stray light based on the scaling of known stray light contribution,
  ;each order separately. Orders 0 and 1 are scaled using order 2
  if (stray gt 0.) then for order_index=0,7 do coef[order_index]=index_straylight[order_index]/dif_straylight_pos[order_index]
  if (stray lt 0.) then for order_index=0,7 do coef[order_index]=index_straylight[order_index]/dif_straylight_neg[order_index]
 
  th0=median(sp[50:150])
  th1=median(sp[460:560])
  th2=median(sp[900:1000])
  if (th2 GT abs(0.5*index_straylight[2]) and th2 gt 0.005) then coef[2]=coef[3]
  if (th1 GT abs(0.5*indpos1) and th1 gt 0.005) then coef[1]=coef[2]
  if (th0 GT abs(0.5*indpos0) and th0 gt 0.005) then coef[0]=coef[1]
  
  for aq=0, n_elements(straypos)-1 do begin
    for order_index=0,7 do $
      sp[order_index*432:(order_index+1)*432-1,straypos[aq]]=sp[order_index*432:(order_index+1)*432-1,straypos[aq]]-$
      straylight_spectrum_model_pos[order_index*432:(order_index+1)*432-1]*coefpos[order_index,aq]
  endfor

  for aq=0, n_elements(strayneg)-1 do begin
    for order_index=0,7 do $
      sp[order_index*432:(order_index+1)*432-1,strayneg[aq]]=sp[order_index*432:(order_index+1)*432-1,strayneg[aq]]-$
      straylight_spectrum_model_neg[order_index*432:(order_index+1)*432-1]*coefneg[order_index,aq]
  endfor



  sp_corrected=sp



  return, sp_corrected

end
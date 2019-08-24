pro h_filter_bad_bands

dirname='/volumes/planeto/virtis/Rosetta/Archive/DATA'
fname='~/VIRTIS_H_file_lists/T_QUB_files_lists/T_QUB_files_list_MTP015.txt'
nfiles = FILE_LINES(fname)
file_list = STRARR(nfiles)
OPENR, lun, fname,/GET_LUN
READF, lun, file_list
FREE_LUN, lun
file_list=strmid(file_list, 1)
file_list=strcompress(dirname+file_list, /remove_all)
nspec=0
spectra=0
type = strmid(file_list[0], 2, /reverse_offset)
for i_file=0, nfiles-1 do begin
  
  file=file_list[i_file]
  
  cube = virtispds(file, /silent)
  s=cube.qube_dim
  data=cube.qube
  if type eq 'QUB' then begin
    data=reform(data,s[0], s[1]*s[2])
    nsp=s[1]*s[2]
  endif else begin
    nsp=s[1]
  endelse
  
  spectra_n=fltarr(s[0],nspec+nsp)
  spectra_n[*,0:nspec-1]=spectra
  spectra_n[*,nspec:nspec+nsp-1]=data
  spectra=spectra_n
  spectra_n=0
  nspec=nspec+nsp     

  print, 'added file #', i_file+1, '    among ',nfiles,' files'
endfor
;std=fltarr(s[0])
;me=fltarr(s[0])
;for i=0,s[0]-1 do std[i]=stddev( spectra[i,*]) ; noob version
;for i=0,s[0]-1 do me[i]=mean( spectra[i,*]) ;noob version

print, 'computing statistical moments'
mo=moment(spectra,dimension=2)
wl=cube.table[0,*]
var='mo !!!! mo= 4 first statistical moments : m[*,0]=mean, m[*,1]=variance, m[*,2]=skewness, m[*,3]=kurtosis'
save, mo, var, filename='~/Programmes/pro_idl/save_bad_bands-MPT015.sav'
plot=plot_virtish(mo[3])
end


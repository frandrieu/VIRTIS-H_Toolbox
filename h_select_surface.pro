pro h_select_surface

  dirname='/volumes/planeto/virtis/Rosetta/Archive/DERIVED-DATA'
  fname='~/VIRTIS_H_file_lists/GE5_files_lists/T_GE5_files_list_MTP015.txt'
  nfiles = FILE_LINES(fname)
  file_list = STRARR(nfiles)
  OPENR, lun, fname,/GET_LUN
  READF, lun, file_list
  FREE_LUN, lun
  file_list=strmid(file_list, 1)
  file_list=strcompress(dirname+file_list, /remove_all)


  for i_file=0, nfiles-1 do begin

    file=file_list[i_file]

    cube = virtispds(file, /silent)

    data=cube.qube

    concat=[concat,data]
    print, (cube.Qube(95,0:10)), format='(B16.16)'
  endfor


end


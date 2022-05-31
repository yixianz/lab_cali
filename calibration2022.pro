pro calibration2022, SIDE = SIDE, ASIC=ASIC, SOURCE=SOURCE
  if not keyword_set(side) then side = 'pside'
  if not keyword_set(asic) then asic = 2
  if not keyword_set(source) then source = "Fe"

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; in this method, must choose detector 0-6
  ; For the FEC07:
  detnum = 3
  ; For the FEC09:
  ;detnum = 2
  ;
  ; change directory of data
  dir = '/Users/foxsigse3/source/usbgse3/'
  ;
  ; Fe 55 files
  f_Fe = ["data_220502_191438.dat", "data_220504_203218.dat", "data_220504_210833.dat"]
  ; Fe 55 peak locations
  fePeaks = [5.89]
  
  ; Am 241 files
  f_Am = ["data_220419_170550.dat", "data_220504_182729.dat", "data_220504_185808.dat", "data_220504_192923.dat"]
  ; Am 241 peak locations
  amPeaks = [13.9, 17.611, 20.9, 26.3, 59.6]
  
  ; Ba 133
  f_Ba = ["data_220502_161825.dat", "data_220502_162538.dat", "data_220502_163652.dat", "data_220502_170709.dat", "data_220502_173723.dat"]
  ; Ba 133 peak locations
  baPeaks = [30.0, 33.0]
  
  ; energy histogram binsize
  eBinsize = 0.5
  
  ; ADC histogram binsize
  chBinsize = 0.5
  
  ;Setting bad channels to be ignored when processing the data (noisy strips)
  badch=intarr(4,64)
  badch(0,0)=1
  badch(0,1)=1
  badch(0,2)=1
  badch(0,3)=1
  badch(0,4)=1 ; not on FOXSI list
  badch(0,5)=1 ; not on FOXSI list

  badch(0,8)=1
  badch(0,9)=1
  badch(0,10)=1
  badch(0,11)=1

  badch(0,18)=1
  badch(0,19)=1

  badch(0,21)=1
  badch(0,22)=1
  badch(0,23)=1 ; not on FOXSI list

  badch(0,26)=1
  badch(0,27)=1

  badch(0,30)=1
  badch(0,31)=1
  badch(0,32)=1
  badch(0,33)=1

  badch(0,35)=1
  badch(0,36)=1

  badch(0,42)=1
  badch(0,43)=1
  badch(0,44)=1
  badch(0,45)=1

  badch(1,32)=1
  badch(1,33)=1

  badch(1,63)=1

  badch(2,63)=1

  badch(3,0)=1
  badch(3,1)=1

  badch(3,17)=1
  badch(3,18)=1
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ; chooses source files to use
  if source eq "Am" then begin
    f = f_Am
    peaks = amPeaks
  endif 
  if source eq "Fe" then begin
    f = f_Fe
    peaks = fePeaks
  endif 
  if source eq "Ba" then begin
    f = f_Ba
    peaks = baPeaks
  endif 
  if source eq "Ni" then begin
      f = f_Ni
      peaks = niPeaks
  endif
  
  print, "Analysing a ", source, " source on the ", side 
  
  ; loop over all data files to combine them
  for i = 0, n_elements(f) - 1 do begin
    ; error handling
    if file_test(f[i]) EQ 0 then i++
    
    code_for_zach, datafile=f[i], SIDE=side, ASIC=asic, SEECH=seech, BADCH=bach
    
    print, "datafiles analyzed: ", i + 1
    
    ;stop
  endfor
  print, "Finished!"
end
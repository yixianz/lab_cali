;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FUNCTION MAKEHIST_FROM4FILE, source = source, noplot = noplot
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
  if not keyword_set(noplot) then noplot=0
  
  ; Output events on the n-side and the p-side to a file
  ;openu, 4, "multiStripEvents.txt"
  ;
  ;; find average and difference
  ;for i = 0, 199 do printf, 4, sbins_chan[i], s_hist_chan[i], d_hist_chan[i], csa_hist_chan[i], all_hist_chan[i]
  ;;
  ;close, 4
  ;
  ;stop
  
  hist = fltarr(200, 64,  4, 2)

  for as=0, 3 do begin
      ; open file with current asic data
      fname = source + "Spec_A" + strtrim(as, 1) + ".txt"
      print, "reading from ", fname
      openr, 4, fname
      
      line = ''
      lineArr = dblarr(1, 65)
      for i = 0, 199 do begin
        ; read line
        readf, 4, line
        
        lineArr = strsplit(line,',',/extract)
        
        for k = 0, 63 do begin
          ; save fisr element as bins
          hist[i, k, as, 0] = lineArr[0]
          hist[i, k, as, 1] = lineArr[k + 1]
        endfor
      endfor
      close, 4
  endfor

  ; save data in current directory with chosen name, for easy recall.
  ;save, a0, a1, a2, a3, file = savefile

  if noplot ne 1 then begin
  window, xsize = 800, ysize = 800
  ;x_axis = indgen(1124)-100
 !p.multi = [0, 2, 2]
  mm = max((rebin(hist, 200, 1, 4, 2))(*,0,*,1))
  plot, (rebin(hist, 200, 1, 4, 2))(*, 0, 0, 0), (rebin(hist, 200, 1, 4, 2))(*, 0, 0, 1), xrange = [-100, 500], yrange = [0.01, mm], $
    xtitle = 'ASIC 0 raw counts', psym = 10;,/ylog
  plot, (rebin(hist, 200, 1, 4, 2))(*, 0, 1, 0), (rebin(hist, 200, 1, 4, 2))(*, 0, 1, 1), xrange = [-100, 500], yrange = [0.01, mm], $
    xtitle = 'ASIC 1 raw counts', psym = 10;,/ylog
  plot, (rebin(hist, 200, 1, 4, 2))(*, 0, 2, 0), (rebin(hist, 200, 1, 4, 2))(*, 0, 2, 1), xrange = [-100, 500], yrange = [0.01, mm], $
    xtitle = 'ASIC 2 raw counts', psym = 10;,/ylog
  plot, (rebin(hist, 200, 1, 4, 2))(*, 0, 3, 0), (rebin(hist, 200, 1, 4, 2))(*, 0, 3, 1), xrange = [-100, 500], yrange = [0.01, mm], $
    xtitle = 'ASIC 3 raw counts', psym = 10;,/ylog
endif
                                ; also store a copy of the save file in data storage directory
;  if n_elements(file) eq 1 then save_name = file else save_name = file[0]
;  if keyword_set(subtract_common) then save_name = save_name + '_sub'
;  save_name = save_name + '.sav'
;  save, a0, a1, a2, a3, file = save_name
  
  return, hist
  
END

pro code_for_zach, datafile=datafile, SIDE=SIDE, ASIC=ASIC, SEECH=SEECH, BADCH=BADCH

  ;Here, you can change which side of the detector we are using to determine event types.
if not keyword_set(side) then side = 'nside'
if not keyword_set(asic) then asic = 0

;asic = 0

;For this to run, the routines in https://github.com/foxsi/calsoft.git should be in your IDL path. 
;If this isn't in your default path, add a path to it like:
;add_path, '~/foxsi/detector/calsoft-master/'

;Reading data into a structure file if you haven't already
if file_test('struct_'+datafile) EQ 0 then begin
	;data = read_data_struct_cal(datafile)
	data = formatter_packet(datafile, 3)
	str = 'struct_'+datafile
	save, data, file=str
endif

;Set path to peaksfile 
;peaksfile='./peaks_fe_3am_cdte_fec7_Al.sav'
peaksfile='./zachPeaks.sav'

;Setting bad channels to be ignored when processing the data (noisy strips)
if not keyword_set(badch) then begin 
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
endif

; requested channels to interpolate
if not keyword_set(seech) then begin 
seech=intarr(4,64)
seech(0, 38) = 1
seech(0, 39) = 1
seech(0, 40) = 1
seech(0, 41) = 1
seech(0, 42) = 1

seech(1, 25) = 1
seech(1, 26) = 1
seech(1, 27) = 1
seech(1, 28) = 1
seech(1, 29) = 1
seech(1, 30) = 1
seech(1, 31) = 1

seech(2, 33) = 1
seech(2, 34) = 1
seech(2, 35) = 1
seech(2, 36) = 1
seech(2, 37) = 1
seech(2, 38) = 1
seech(2, 39) = 1
seech(2, 40) = 1
seech(2, 41) = 1
seech(2, 42) = 1

seech(3, 25) = 1
seech(3, 26) = 1
seech(3, 27) = 1
seech(3, 28) = 1
endif

;Now, we make a data structure containing events in energy-space, with only events above the 
;thresholds. Again, we check if we already did this so it only needs to be done once. 
fname=strsplit('struct_'+datafile,'_',/extract)
f1=strsplit(fname[3],'.',/extract)
specfname = 'eventwisesp_'+fname[2]+'_'+f1[0]+'.txt'
if file_test(specfname) EQ 0 then begin
  print, "Creating new energy-space data structure"
  
	;print, badch
	;Making a data structure containing events in energy-space, with only events above the thresholds.
	eventwise_spectra=eventdata_spectra('struct_'+datafile, peaksfile=peaksfile, thrn=4., badch=badch, /sub)
	save,eventwise_spectra, file = specfname
endif else begin
  print, "Using energy-space data structure from ", specfname
  
	restore, specfname
endelse

stop

;Additionally, we make a data structure containing events in channel-space, with only events above the 
;thresholds. Again, we check if we already did this so it only needs to be done once. 
;NOTE THAT WE USED THE GAIN CALIBRATION TO DO THRESHOLDING - OTHERWISE SUB-THRESHOLD EVENTS WOULD REDUCE
;THE NUMBER OF RECORDED "SINGLE STRIP EVENTS"
specfname = 'chan_eventwisesp'+fname[2]+'_'+f1[0]+'.txt'
if file_test(specfname) EQ 0 then begin
  print, "Creating new channel-space data structure"
  
	;print, badch
	;Making a data structure containing events in energy-space, with only events above the thresholds.
	eventwise_spectra_chan=eventdata_spectra_channel('struct_'+datafile, peaksfile=peaksfile, thrn=4., badch=badch, /sub) ;; WE REMOVED /cmn_med keyword cause it made it so there were no single or double strip events
	save,eventwise_spectra_chan, file = specfname
endif else begin
  print, "Using channel-space data structure from ", specfname
  
	restore, specfname
endelse


;================================================================================================================
;================================================================================================================
;We are now done with data processing and want to actually make spectra with single strip, double strip, etc.
;We will do this with both the energy-space and channel-space arrays.

;================================================================================================================
;================================================================================================================

print, "Creating single/double event spectra in energy space for the ", side

;FIRST, IN ENERGY SPACE:

data = eventwise_spectra.eventdata_spec


SINGLE_FRAMES = []
DOUBLE_FRAMES = []
double_csa_energies = []

if side EQ 'pside' then begin
	pside_data = data[2:3, *, *]
	;All non-zero hits on p-side: to be 'total' spectrum
	nz = pside_data[where(pside_data NE 0.)]
	
	;Now, looking at frames individually
	for i=0, n_elements(data[0,0,*])-1 do begin
		frame = data[*,*,i]
		pside = where(frame[2:3,*] NE 0.)
		;If it's a single strip event:
		if n_elements(pside) EQ 1 and total(pside) NE -1. then begin
			SINGLE_FRAMES = [SINGLE_FRAMES, i]
		endif
		;If two strips register:
		if n_elements(pside) EQ 2 then begin
			as2 = where(frame[2,*] NE 0.)
			;If they are both in ASIC 2:
			if n_elements(as2) EQ 2 then begin
				;If they are actually adjacent:
				if as2[1]-as2[0] EQ 1 then begin
					DOUBLE_FRAMES = [DOUBLE_FRAMES, i]
					double_csa_energies = [double_csa_energies, total(frame[2,*])]
				endif
			endif
			as3 = where(frame[3,*] NE 0.)
			;If they are both in ASIC3:
			if n_elements(as3) EQ 2 then begin
				;If they are actually adjacent:
				if as3[1]-as3[0] EQ 1 then begin
					DOUBLE_FRAMES = [DOUBLE_FRAMES, i]
					double_csa_energies = [double_csa_energies, total(frame[3,*])]
				endif
			endif		
		endif
	endfor
	singleEventChannels = dblarr(4,64,n_elements(SINGLE_FRAMES))

	for i = 2, 3 do begin
	  for j = 0, n_elements(SINGLE_FRAMES) - 1 do begin
	    for k = 0, 63 do begin
	      if data[i, k, SINGLE_FRAMES[j]] NE 0. then begin
	        singleEventChannels[i, k, j] = data[i, k, SINGLE_FRAMES[j]]
	      endif
	    endfor
	  endfor
	endfor
	
	;if n_elements(SINGLE_FRAMES)
	singles_data = data[2:3,*, SINGLE_FRAMES]
	doubles_data = data[2:3,*, DOUBLE_FRAMES]
endif

;See documentation on pside loop, it's the same process. 
if side EQ 'nside' then begin
	nside_data = data[0:1, *, *]
	;All non-zero hits on p-side: to be 'total' spectrum
	nz = nside_data[where(nside_data NE 0.)]
	for i=0, n_elements(data[0,0,*])-1 do begin
		frame = data[*,*,i]
		nside = where(frame[0:1,*] NE 0.)
		if n_elements(nside) EQ 1 and total(nside) NE -1. then begin
			SINGLE_FRAMES = [SINGLE_FRAMES, i]
		endif
		if n_elements(nside) EQ 2 then begin
			as0 = where(frame[0,*] NE 0.)
			if n_elements(as0) EQ 2 then begin
				if as0[1]-as0[0] EQ 1 then begin
					DOUBLE_FRAMES = [DOUBLE_FRAMES, i]
					double_csa_energies = [double_csa_energies, total(frame[0,*])]
				endif
			endif
			as1 = where(frame[1,*] NE 0.)
			if n_elements(as1) EQ 2 then begin
				if as1[1]-as1[0] EQ 1 then begin
					DOUBLE_FRAMES = [DOUBLE_FRAMES, i]
					double_csa_energies = [double_csa_energies, total(frame[1,*])]
				endif
			endif		
		endif	
	endfor
	singleEventChannels = dblarr(4,64,n_elements(SINGLE_FRAMES))

	for i = 0, 1 do begin
	  for j = 0, n_elements(SINGLE_FRAMES) - 1 do begin
	    for k = 0, 63 do begin
	      if data[i, k, SINGLE_FRAMES[j]] NE 0. then begin
	        singleEventChannels[i, k, j] = data[i, k, SINGLE_FRAMES[j]]
	      endif
	    endfor
	  endfor
	endfor
	
	singles_data = data[0:1,*, SINGLE_FRAMES]
	doubles_data = data[0:1,*, DOUBLE_FRAMES]
endif


binsize = 0.5

if n_elements(SINGLE_FRAMES) GT 0 then begin
  ;We've previously found all the FRAMES with a single-strip event, here we only take the actual
  ;single strip event energies (removes all the 0s)
  nz_singles = singles_data[where(singles_data NE 0.)]

  ;Single event spectrum histogram
  s_hist = histogram(nz_singles, binsize=binsize, nbins=200, min=0, locations=sbins)
  
  ; single event spectrum per channel
  !p.multi = [0, 8, 8]
  
  s_hist_sChan = dblarr(64, 200)
  
  for i = 0, 63 do begin
    index = where(singleEventChannels(ASIC, i, *) NE 0.)
    if n_elements(index) gt 1 then begin
      nz_singlesChan = singleEventChannels(ASIC, i, index)
      s_hist_sChan[i, *] = histogram(nz_singlesChan, binsize=binsize, nbins=200, min=0, locations=sbins_chan)
    endif
    plot, sbins, s_hist_sChan[i, *], yrange = [1., 100.], xrange=[0., 80.]
  endfor
  
endif

if n_elements(DOUBLE_FRAMES) GT 0 then begin
  nz_doubles = doubles_data[where(doubles_data NE 0.)]

  ;Double event spectrum histogram
  d_hist = histogram(nz_doubles, binsize=binsize, nbins=200, min=0, locations=dbins)
  
  ;CSA histogram from double pixel sums
  csa_hist = histogram(double_csa_energies, binsize=binsize, nbins=200, min=0, locations=cbins)
endif


;All event spectrum histogram
all_hist = histogram(nz, binsize=binsize, nbins=200, min=0, locations=abins)

print, "# of single events: ", size(nz_singles), "# of double events: ", size(nz_doubles), "# of nonzero events: ",size(nz)

; Output events on the n-side and the p-side to a file
openw, 4, "feSpec.txt"

; find average and difference
for i = 0, 199 do printf, 4, abins[i], all_hist[i]
;
close, 4

print, "done"


;NOW, IN CHANNEL SPACE: (note that code is exactly the same)

print, "Creating single/double event spectra in channel space for the ", side

;data = eventwise_spectra_chan.eventdata_spec
;
;
;SINGLE_FRAMES = []
;DOUBLE_FRAMES = []
;double_csa_energies = []
;
;if side EQ 'pside' then begin
;	pside_data = data[2:3, *, *]
;	;All non-zero hits on p-side: to be 'total' spectrum
;	nz = pside_data[where(pside_data NE 0.)]
;	
;	;Now, looking at frames individually
;	for i=0, n_elements(data[0,0,*])-1 do begin
;		frame = data[*,*,i]
;		pside = where(frame[2:3,*] NE 0.)
;		;If it's a single strip event:
;		if n_elements(pside) EQ 1 and total(pside) NE -1. then begin
;			SINGLE_FRAMES = [SINGLE_FRAMES, i]
;		endif
;		;If two strips register:
;		if n_elements(pside) EQ 2 then begin
;			as2 = where(frame[2,*] NE 0.)
;			;If they are both in ASIC 2:
;			if n_elements(as2) EQ 2 then begin
;				;If they are actually adjacent:
;				if as2[1]-as2[0] EQ 1 then begin
;					DOUBLE_FRAMES = [DOUBLE_FRAMES, i]
;					double_csa_energies = [double_csa_energies, total(frame[2,*])]
;				endif
;			endif
;			as3 = where(frame[3,*] NE 0.)
;			;If they are both in ASIC3:
;			if n_elements(as3) EQ 2 then begin
;				;If they are actually adjacent:
;				if as3[1]-as3[0] EQ 1 then begin
;					DOUBLE_FRAMES = [DOUBLE_FRAMES, i]
;					double_csa_energies = [double_csa_energies, total(frame[3,*])]
;				endif
;			endif		
;		endif
;	endfor
;  
;  singleEventChannels = dblarr(4,64,n_elements(SINGLE_FRAMES))
;	for i = 2, 3 do begin
;	 for j = 0, n_elements(SINGLE_FRAMES) - 1 do begin
;	   for k = 0, 63 do begin
;	     if data[i, k, SINGLE_FRAMES[j]] NE 0. then begin
;	         singleEventChannels[i, k, j] = data[i, k, SINGLE_FRAMES[j]]
;	     endif     
;	   endfor
;	 endfor
;	endfor
;	
;	singles_data = data[2:3,*, SINGLE_FRAMES]
;	doubles_data = data[2:3,*, DOUBLE_FRAMES]
;endif
;
;;See documentation on pside loop, it's the same process. 
;if side EQ 'nside' then begin
;	nside_data = data[0:1, *, *]
;	;All non-zero hits on p-side: to be 'total' spectrum
;	nz = nside_data[where(nside_data NE 0.)]
;	for i=0, n_elements(data[0,0,*])-1 do begin
;		frame = data[*,*,i]
;		nside = where(frame[0:1,*] NE 0.)
;		if n_elements(nside) EQ 1 and total(nside) NE -1. then begin
;			SINGLE_FRAMES = [SINGLE_FRAMES, i]
;		endif
;		if n_elements(nside) EQ 2 then begin
;			as0 = where(frame[0,*] NE 0.)
;			if n_elements(as0) EQ 2 then begin
;				if as0[1]-as0[0] EQ 1 then begin
;					DOUBLE_FRAMES = [DOUBLE_FRAMES, i]
;					double_csa_energies = [double_csa_energies, total(frame[0,*])]
;				endif
;			endif
;			as1 = where(frame[1,*] NE 0.)
;			if n_elements(as1) EQ 2 then begin
;				if as1[1]-as1[0] EQ 1 then begin
;					DOUBLE_FRAMES = [DOUBLE_FRAMES, i]
;					double_csa_energies = [double_csa_energies, total(frame[1,*])]
;				endif
;			endif		
;		endif
;	endfor
;	singleEventChannels = dblarr(4,64,n_elements(SINGLE_FRAMES))
;
;	for i = 0, 1 do begin
;	  for j = 0, n_elements(SINGLE_FRAMES) - 1 do begin
;	    for k = 0, 63 do begin
;	      if data[i, k, SINGLE_FRAMES[j]] NE 0. then begin
;	        singleEventChannels[i, k, j] = data[i, k, SINGLE_FRAMES[j]]
;	      endif
;	    endfor
;	  endfor
;	endfor
;	
;	singles_data = data[0:1,*, SINGLE_FRAMES]
;	doubles_data = data[0:1,*, DOUBLE_FRAMES]
;endif
;
;binsize=3
;
;if n_elements(SINGLE_FRAMES) GT 0 then begin
;  ;We've previously found all the FRAMES with a single-strip event, here we only take the actual
;  ;single strip event energies (removes all the 0s)
;  nz_singles = singles_data[where(singles_data NE 0.)]
;  
;  ;Single event spectrum histogram
;  s_hist_chan = histogram(nz_singles, binsize=binsize, nbins=200, min=0, locations=sbins_chan)
;  
;  ; single event spectrum per channel
;  !p.multi = [0, 8, 8]
;  
;  s_hist_sChan = dblarr(64, 200)
;  
;  for i = 0, 63 do begin
;    index = where(singleEventChannels(ASIC, i, *) NE 0.)
;    iSize = n_elements(index)
;    ;print, index
;    if iSize gt 1 then begin
;      nz_singlesChan = dblarr(1, iSize)
;      ;for j = 0, iSize - 1 do begin
;      nz_singlesChan = singleEventChannels(ASIC, i, index)
;      ;endfor
;      
;      s_hist_sChan[i, *] = histogram(nz_singlesChan, binsize=3, nbins=200, min=0, locations=sbins_chan)
;    endif
;    plot, sbins_chan, s_hist_sChan[i, *], yrange = [1., 35.], xrange=[0., 500.]
;  endfor
;endif
;
;file = "savHist_A" + string(ASIC) + "_" + fname[2] + "_" + f1[0] + ".txt"
;
;hist = dblarr(200, 65)
;hist[*, 0] = sbins_chan
;for i = 1, 64 do begin
;  hist[*, i] = s_hist_sChan[i - 1, *]
;endfor
;
;write_csv, file, transpose(hist)
;
;print, file, " saved..."
;
;if n_elements(DOUBLE_FRAMES) GT 0 then begin
;  nz_doubles = doubles_data[where(doubles_data NE 0.)]
;  
;  ;Double event spectrum histogram
;  d_hist_chan = histogram(nz_doubles, binsize=binsize, nbins=200, min=0, locations=dbins_chan)
;  
;  ;CSA histogram from double pixel sums
;  csa_hist_chan = histogram(double_csa_energies, binsize=binsize, nbins=200, min=0, locations=cbins_chan)
;endif
;
;;All event spectrum histogram
;all_hist_chan = histogram(nz, binsize=binsize, nbins=200, min=0, locations=abins_chan)
;
;print, "# of single events: ", size(nz_singles), "# of double events: ", size(nz_doubles), "# of nonzero events: ", size(nz)


;================================================================================================================
;================================================================================================================
;Time for plotting
;================================================================================================================
;================================================================================================================

;popen, 'pretty_spectrum.ps', $
;		xsi=8, ysi=10


;!Y.margin=4.
;!X.margin=4.
;ch=1.1
;
;; set line thickness
;th=1 ;4
;lnth=1 ;4
;
;; set character size and width
;fth=1; 2
;charsize=2 ;0.5
;
;; clear display then three vertically stacked plots
;!p.multi=[0,1,1]
;
;; get colors/labels
;loadct, 2
;lables = ['All Events', 'Single Strip', 'Double Strip', 'Double CSA']
;colors = [0, 40, 80, 180]

;================================================================================================================
;================================================================================================================

; 80., 3000.0

;Plotting all spectra - energy space
;plot, abins, all_hist, yrange=[1., 1e5.], xrange=[0.,65.], thick=th, xthick=th, ythick=th, font=-1, $
;		charthick=fth, charsize=charsize, title=date, xtitle='Energy (keV)', ytitle='Counts/bin', $
;	  psym=10, xstyle=1
;oplot, sbins, s_hist, color=40, thick=th, psym=10
;oplot, dbins, d_hist, color=80, thick=th, psym=10
;oplot, cbins, csa_hist, color=180, thick=th, psym=10
;al_legend, lables, textcol=colors, box=1, /right, /top, /clear, charsi=1


;;Plotting all spectra - channel space
;plot, abins_chan, all_hist_chan, yrange=[1., 5000.], xrange=[0.,1000.], thick=th, xthick=th, ythick=th, font=-1, $
;		charthick=fth, charsize=charsize, title=date, xtitle='Energy (ADC)', ytitle='Counts/bin', $
;		psym=10, xstyle=1
;oplot, sbins_chan, s_hist_chan, color=40, thick=th, psym=10
;oplot, dbins_chan, d_hist_chan, color=80, thick=th, psym=10
;oplot, cbins_chan, csa_hist_chan, color=180, thick=th, psym=10
;;al_legend, lables, textcol=colors, box=1, /right, /top, /clear, charsi=1

;================================================================================================================
;================================================================================================================

; reset multiplot
;!p.multi=0
;!Y.margin=[4.,2.]
;pclose
;DEVICE, /CLOSE
;spawn, 'open pretty_spectrum.ps'


;================================================================================================================
;================================================================================================================

;; save multiStrip event data

; Output events on the n-side and the p-side to a file
;openu, 4, "multiStripEvents.txt"
;
;; find average and difference
;for i = 0, 199 do printf, 4, sbins_chan[i], s_hist_chan[i], d_hist_chan[i], csa_hist_chan[i], all_hist_chan[i]
;;
;close, 4
;
;stop


; output single event spectra for all interpolation channels

; make array of histogram values for each channel of interest
;channels = where(seech[ASIC, *] EQ 1, nCh)
;channels = [-1, channels]
;interpChan = dblarr(n_elements(sbins_chan) + 1, nCh + 1) ; read_ascii("interpChanSpec.txt")
;interpChan[0, *] = transpose(channels)

;; make array to save old data
;oldInterpChan = dblarr(n_elements(sbins_chan) + 1, nCh + 1)
;; read current values in file
;openr, 7, "interpChanSpec.txt"
;readf, 7, oldInterpChan, format = '(91(F19.15)'
;close, 7

; save first col as bins
;interpChan[1:*, 0] = sbins_chan[*]
;
;; index of current channel in seech
;k = 1
;for i = 0, 63 do begin
;  ; if the current ASIC is one we want to interpolate
;  if seech(ASIC, i) EQ 1 then begin
;    print, k
;    ; add new and old values to column
;    interpChan[1:*, k] = s_hist_sChan[i, *] ;+ oldInterpChan[1:*, k]
;    k += 1
;  endif
;endfor
;

end
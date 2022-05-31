;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO makeSAV
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

npeak=8
peaks=fltarr(npeak+3, 64, 4, 2)

; make histograms
look = 1

histfe = makehist_from4file(source = "fe", noplot = look)
histba = makehist_from4file(source = "ba", noplot = look)
histam = makehist_from4file(source = "am", noplot = look)

print, "creating n-side data..."

; n-side
for asic=0, 1 do begin
    for ch=0, 63 do begin
        print, asic, ch
      
        xxfe=histfe(*, ch, asic,0)
        yyfe=histfe(*, ch, asic,1)
        xxam=histam(*, ch, asic,0)
        yyam=histam(*, ch, asic,1)
        xxba=histba(*, ch, asic,0)
        yyba=histba(*, ch, asic,1)
        
        ; extend values       [0  , 1 , 2   , 3,  , 4    , 5  , 6  , 7   , 8  , 9   , 10
        peaks(*, ch, asic, 1)=[0.0,0.0,5.895,13.93,17.611,20.9,26.3,30.85,59.54,0.0,0.0]
        peaks(0, ch, asic, 1)=peaks(1, ch, asic, 1)*2-peaks(2, ch, asic, 1)
        peaks(npeak+1, ch, asic, 0)=peaks(npeak  , ch, asic, 0)*2-peaks(npeak-1, ch, asic, 0)
        peaks(npeak+2, ch, asic, 1)=peaks(npeak+1, ch, asic, 1)*2-peaks(npeak, ch, asic, 1)
        
        ; Am peaks
        if asic EQ 0 then begin
          peaks(1, ch, asic, 0) = find_peak(xxam, yyam, -20, 20, 1, 1)
          peaks(3, ch, asic, 0) = find_peak(xxam,yyam,50, 75, 1, 1)
          peaks(4, ch, asic, 0) = find_peak(xxam,yyam,peaks(3,ch, asic, 0) + 5, 100, 1, 1)
          peaks(5, ch, asic, 0) = find_peak(xxam,yyam,100, 150, 1, 1)
          peaks(6, ch, asic, 0) = find_peak(xxam,yyam,peaks(5, ch, asic, 0) + 5, 150, 1, 1)
          peaks(7, ch, asic, 0) = find_peak(xxam,yyam,285, 350, 1, 1)
        endif
        if asic EQ 1 then begin 
          peaks(1, ch, asic, 0) = 0
          peaks(3, ch, asic, 0) = find_peak(xxam,yyam,50, 100, 1, 1)
          peaks(4, ch, asic, 0) = find_peak(xxam,yyam,peaks(3,ch, asic, 0) + 5, 150, 1, 1)
          peaks(5, ch, asic, 0) = find_peak(xxam,yyam,peaks(4,ch, asic, 0) + 5, 170, 1, 1)
          peaks(6, ch, asic, 0) = find_peak(xxam,yyam,160, 200, 1, 1)
          peaks(7, ch, asic, 0) = find_peak(xxam,yyam,350, 500, 1, 1)
        endif        
        
        ; Fe peaks
        peaks(2, ch, asic, 0)=find_peak(xxfe,yyfe,0, 50, 1, 1)
        
        ; Ba peaks
        if asic EQ 0 then peaks(6, ch, asic, 0)=find_peak(xxba,yyba,150, 200,1,1)
        if asic EQ 1 then peaks(6, ch, asic, 0)=find_peak(xxba,yyba,200, 250,1,1)
        
        peaks(0, ch, asic, 0)=peaks(1, ch, asic, 0)*2-peaks(2, ch, asic, 0)
        peaks(npeak+1, ch, asic, 0)=peaks(npeak  , ch, asic, 0)*2-peaks(npeak-1, ch, asic, 0)
        peaks(npeak+2, ch, asic, 0)=peaks(npeak+1, ch, asic, 0)*2-peaks(npeak, ch, asic, 0)
    endfor
endfor

print, "creating p-side data..."

; p-side
for asic=2, 3 do begin
    for ch=0, 63 do begin
        print, asic, ch

        xxfe=histfe(*, ch, asic,0)
        yyfe=histfe(*, ch, asic,1)
        xxam=histam(*, ch, asic,0)
        yyam=histam(*, ch, asic,1)
        xxba=histba(*, ch, asic,0)
        yyba=histba(*, ch, asic,1)
        
        ; extend values       [0  , 1 , 2   , 3,  , 4    , 5  , 6  , 7   , 8  , 9   , 10
        peaks(*, ch, asic, 1)=[0.0,0.0,5.895,13.93,17.611,20.9,26.3,30.85,33.0,59.54,0.0]
        peaks(0, ch, asic, 1)=peaks(1, ch, asic, 1)*2-peaks(2, ch, asic, 1)
        peaks(npeak+2, ch, asic, 1)=peaks(npeak+1, ch, asic, 1)*2-peaks(npeak, ch, asic, 1)
        
        ; Am peaks
        peaks(1, ch, asic, 0) = 0
        peaks(3, ch, asic, 0) = find_peak(xxam,yyam,50, 100, 1, 1)
        peaks(4, ch, asic, 0) = find_peak(xxam,yyam,peaks(3,ch, asic, 0) + 5, 150, 1, 1)
        peaks(5, ch, asic, 0) = find_peak(xxam,yyam,peaks(4,ch, asic, 0) + 5, 150, 1, 1)
        peaks(6, ch, asic, 0) = find_peak(xxam,yyam,150, 200, 1, 1)
        peaks(8, ch, asic, 0) = find_peak(xxam,yyam,350, 500, 1, 1)
        
        ; Fe peaks
        peaks(2, ch, asic, 0)=find_peak(xxfe,yyfe, 10,100, 1, 1)
        
        ; Ba peaks
        peaks(6, ch, asic, 0)=find_peak(xxba,yyba,200,250,1,1)
        peaks(7, ch, asic, 0)=find_peak(xxba,yyba,251,400,1,1)
       

        peaks(0, ch, asic, 0)=peaks(1, ch, asic, 0)*2-peaks(2, ch, asic, 0)
        peaks(npeak+2, ch, asic, 0)=peaks(npeak+1, ch, asic, 0)*2-peaks(npeak, ch, asic, 0)
    endfor
endfor

print, "finished..."

save,peaks,file='zachPeaks.sav'

END


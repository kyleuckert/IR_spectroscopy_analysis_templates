pro Average_Time_Resolved_Scans, disk, filename, Nsweeps
;
;REGISTERS EACH SPECTRUM IN A MULTI-SWEEP RESULT TO A SINGLE SWEEP CHOSEN AS THE REFERENCE.
;WE USE THE STRONG H2O FEATURES CENTERED NEAR 2.8 MICRONS AS THE FIDUCIALS (THESE ARE THE SAME FEATURES WE WILL CORRECT OUT) 
;THE CO-REGISTERED SPECTRA ARE THEN COADDED TO GET THE AVERAGE SPECTRUM
;THIS ROUTINE IS USED TO COMPENSATE (PARTLY) FOR JITTER IN THE [OLD] HP RF SWEEPER USED FOR THE SPECTROMETER BREADBOARD
;(IT SHOULD NO LONGER BE NECESSARY WHEN THE PRECISION SWEEPER IS IMPLEMENTED)
;
;INPUT FILE:   "<sample_name>_stack.txt"
;  CONSISTS OF Nsweeps+3 COLUMNS AND Nlines ROWS, WHERE
;  Nsweeps IS THE NMBR OF SWEEPS, e.g., 16,32,64,128. (Nsweeps =64 provides adequate SNR for most samples)
;  Nlines IS THE NUMBER OF ANALOG SAMPLES THAT DEFINE A SINGLE SWEEP
;   (Typically Nlines~2400 or thereabouts using the breadboard sampling configuration.
;   Sample point separation is small enough to multiple-sample the AOTF passband function everywhere.)
;  
;  Input file data values are the detector preamp output. (Additional "downstream" gain is used to increase SNR in low-reflectance
;  samples, but this has been divided out, so that all samples are normalized to the same effective gain.)
;  
;  Columns:  line#, freq(MHz), wvl(um), sweep1, sweep2, sweep3, . . .sweep_Nsweeps-1
;  
;  COMMENT: Files are first created in Excel by Xiao and saved as .txt files for IDL input
;
;PATH/FILE (Substitute your own)
;   disk= '/arcturus/kuckert/AOTF/DATA/2013JUN06/'
; 
   ;path= disk+'EPSCoR_ASTID_Project\Breadboard_Evaluation_Sample_Measurements\Mar_2012_Manganese_Oxides\'
   ;filename= 'InfragoldG100_256'
   ;filename= 'MnO2brightG100_256'
;
   path= disk
   ;filename= 'Infragold1'
   ;filename= 'Gypsum'   
;
;READ THE INPUT FILE TWICE, FIRST TIME TO GET Nlines
   hdr=''
   close,1
   openr,1,path + filename+ '.txt'
;
   Nlines=0
   while not eof(1) do begin
     readf,1,hdr
     Nlines= Nlines+1
   endwhile
   close,1
;
   print,'Nlines=',Nlines
;
;THEN LOAD THE DATA
   SweepFreqs= fltarr(Nlines)
   SweepWvls= fltarr(Nlines)
;   Nsweeps=128;256;64
   Refl= fltarr(Nsweeps,Nlines)
   vector= fltarr(Nsweeps)
;
   openr,1,path + filename+ '.txt'
   k=0L
   for i=0,Nlines-1 do begin
     readf,1,k,fr,wv,vector
     SweepFreqs[i]=fr
     SweepWvls[i]=wv
     Refl[*,i]= vector
   endfor
;


SET_PLOT, 'Z'               ; Select the Z buffer output device
dlm_load, 'gif'
write_gif, /close
;SCROLL THROUGH THE Nsweeps SPECTRA JUST TO CHECK THE READ
   ;window,1,xsize=600,ysize=400,title='raw data spectra: '+strcompress(filename)+': Sweep Number: '+strcompress(string(i))
   for j =0,Nsweeps-1 do begin
      plot,SweepFreqs,Refl[j,*],xstyle=1,title='raw data spectra: '+strcompress(filename)+': Sweep Number: '+strcompress(string(j)),yrange=[min(Refl[*,*]),max(Refl[*,*])],ystyle=1;,yrange=[-0.0005,0.002],ystyle=1  ;fullrange
      ;plot,SweepFreqs,Refl[j,*],xrange=[38.0,43.0],xstyle=1,psym=3
      image = TVRD()
      WRITE_GIF, filename+'_animation.gif', image, /multiple, delay_time=1, repeat_count=0
      ;wait,0.1
   endfor
;
set_plot,'x'

;NOW SELECT ONE OF THE SPECTRA AS A REFERENCE, AND FIND THE SET OF X-SHIFTS
;THAT ALIGN EACH SPECTRUM WITH THE REFERENCE SPECTRUM.
;WE CONSIDER ONLY THE WAVELENGTH INTERVAL AROUND THE H2O FEATURE, IN ORDER TO COMPUTE THE SUM
;
   SpecIndices= where(SweepFreqs gt 38.0 and SweepFreqs lt 43.0,count)  ;Just the interval around the strong H2O band
   print,'SpecIndices=',SpecIndices
   Nwindow=100  ;Width of the lag interval.  
   DiffSum= fltarr(Nwindow)
   lag_window= -Nwindow/2 + indgen(Nwindow) ;the lag window 
   x_shifts= fltarr(Nsweeps)  ;The list of x_shifts we're looking for, if there are any
;
   window,2,xsize=600,ysize=400,title='c-corr vs lag'
;
   for j=0,Nsweeps-1 do begin
     cCorrSpec= c_correlate(Refl[j,SpecIndices],Refl[Nsweeps/2,SpecIndices],lag_window)
     plot,lag_window,cCorrSpec
     getmaxIdx= max(cCorrSpec,maxIdx)
     x_shifts[j]= 0.0;lag_window[maxIdx]  ; !X_SHIFTS TEMPORARILY SET TO 0.0
     ;wait,0.2
   endfor
;
;THEN PLOT THE VECTOR OF X_SHIFTS
  window,3,xsize=600,ysize=400,title='x-shift vector'
  plot,findgen(Nsweeps),x_shifts,yrange=[-10.0,10.0],ystyle=1
;
;NOW CREATE AND DISPLAY THE AVERAGE SPECTRUM USING THE ALIGNED (SHIFTED) SET OF CONTRIBUTING SPECTRA
  AverageSpec= fltarr(Nlines)
  for j=0,Nsweeps-1 do AverageSpec= AverageSpec + interpol(Refl[j,*],findgen(Nlines),findgen(Nlines)+x_shifts[j])
  AverageSpec= AverageSpec / Nsweeps ;convert from sum to average
  window,4,xsize=600,ysize=400,title='AvgVector'
  plot,SweepFreqs,AverageSpec,xstyle=1;,xrange=[38,45]
;
;NOW SAVE THE SHIFT-CORRECTED AVG SPECTRUM
  close,1
  openw,1,path + filename + '_avg.txt'
  printf,1, '     Freq        Wvl       AvgRefl'
  for i=0,Nlines-1 do printf,1,SweepFreqs[i],SweepWvls[i],AverageSpec[i],format='(2x,f9.4,2x,f10.5,2x,e12.4)'
  close,1
;
print,'done'
;
end

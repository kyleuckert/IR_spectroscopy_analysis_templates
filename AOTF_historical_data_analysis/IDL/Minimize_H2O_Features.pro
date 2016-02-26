;------------------------------
pro H2O_SpecSyn,WvnSubSet,Dnu,VMR,OutSpec
;
;CREATES AN INTERPOLATED SPECTRUM (10 CM CELL) FOR ANY RESOLUTION AND VOL MIXING RATIO
;USES kabsMatrix (the Ndata X 5 matrix of absorption coeffs)
;
common shared,kabsMatrix,MeasSpec,MeasWvnPts
;
;Compute the Ndata X 5 matrix of transmittance spectra using kabsMatrix and the given VMR
Ndata= n_elements(MeasWvnPts)
TransSpecMatrix= fltarr(Ndata,5) ;Opposite index order of kabsMatrix
for jj=0,4 do TransSpecMatrix[*,jj]= exp(-kabsMatrix[*,jj]*VMR)
  
Dnu_set= [10.0,15.0,20.0,25.0,30.0]
Dnu_step= 5.0
;
Dnu_index= (Dnu-min(Dnu_set)) / Dnu_step
;
FullSpec= interpolate(TransSpecMatrix,Dnu_index,/grid,cubic=-0.5)
OutSpec= interpol(FullSpec,MeasWvnPts,WvnSubSet,/quadratic)
;
end
;
;--------------------------------------
pro GetParam,WvnSubSet,Param,Nsolve
;
common shared,kabsMatrix,MeasSpec,MeasWvnPts
;
count= n_elements(WvnSubSet)
;
;FIND THE POLY COEFFS AND THE nushift IN REGION IMMEDIATELY AROUND THE H2O FEATURES
;Consists of polynomial x H2O transmittance at trial nushift, Dnu and VMR
;
Dnu= Param[4]    ;start parameters
VMR= Param[5]
;
H2O_SpecSyn,WvnSubSet,Dnu,VMR,H2O_Model 
;
Ntrials=400  
nuShiftList=  0.10 * ( findgen(Ntrials) - Ntrials/2.0 )  ;Symmetric about nuShift=0
MeanDevVals= fltarr(Ntrials)
;
window,4,xsize=1000,ysize=500,title= 'In "GetParam": SHIFTED SPEC / H2O MODEL' 
;
MeanDevVals= fltarr(Ntrials)
FOR ii=0,Ntrials-1 DO BEGIN ;FIND NuShift
  MeasSpec_Shifted= interpol(MeasSpec,MeasWvnPts,WvnSubSet+nuShiftList[ii],/lsquadratic)
; Make a trial model & overlay with measurement
  trialSpec= MeasSpec_Shifted/H2O_Model
  result= poly_fit(WvnSubSet,trialSpec,2,yfit=yfit) ;try cubic
  plot,WvnSubSet,trialSpec,xrange=[min(MeasWvnPts),max(MeasWvnPts)],xstyle=1
  oplot,WvnSubSet,yfit
  ;wait,0.1
  MeanDevVals[ii]= total(abs(yfit-trialSpec))/float(count)
  ;print,ii,nuShiftList[ii],MeanDevVals[ii]   
ENDFOR
;
window,5,xsize=1000,ysize=500,title= 'In "GetParam": sum(meanDev) vs nuShiftList: '
plot,nuShiftList,MeanDevVals;,xrange=[min(MeasWvnPts),max(MeasWvnPts)],xstyle=1
;
;GET THE nushift VALUE CORRESPONDING TO MIN ABS DEVIATION
  minval= min(MeanDevVals,minSubscript)
  NuShift= nuShiftList[minSubscript]
  print,'result NuShift=',NuShift
;
PolyCoeffs= [0.,0.,0.]  ;In case we omit the following loop
IF Nsolve EQ 2 THEN BEGIN
  ;NOW THE VMR PARAMETER; MAKE STEP SIZE=0.0005
  MeasSpec_Shifted= interpol(MeasSpec,MeasWvnPts,WvnSubSet+NuShift,/lsquadratic) 
  VMR_vector= 0.005 + 0.0001*findgen(200)
  MeanDevVals= fltarr(200)
  CoeffMatrix= fltarr(3,200)
  wset,4  
  FOR jj=0,199 do begin   ;Find VMR
    H2O_SpecSyn,WvnSubSet,Dnu,VMR_vector[jj],H2O_Model
    trialSpec= MeasSpec_Shifted/H2O_Model
    result= poly_fit(WvnSubSet,trialSpec,2,yfit=yfit)
    plot,WvnSubSet,trialSpec,xrange=[min(MeasWvnPts),max(MeasWvnPts)],xstyle=1
    oplot,WvnSubSet,yfit
    MeanDevVals[jj]= total(abs(yfit-trialSpec))/float(200)
    CoeffMatrix[*,jj]=result
    ;wait,0.1
  ENDFOR
;
  window,6,xsize=1000,ysize=500,title= 'In "Get start param": sum(meanDev) vs VMR: '
  plot,VMR_vector,MeanDevVals;,xrange=[min(MeasWvnPts),max(MeasWvnPts)],xstyle=1
;
;  GET THE VMR VALUE CORRESPONDING TO MIN ABS DEVIATION
     minval= min(MeanDevVals,minSubscript)
     VMR= VMR_vector[minSubscript]
     PolyCoeffs= CoeffMatrix[*,minSubscript] 
     print,'VMR=',VMR
     print,'PolyCoeffs=',PolyCoeffs
ENDIF;  ;THE EXTRA LOOP, IF Nsolve=2, i.e. SOLVING FOR VMR
 ;
;RETURN THE BEST MODEL ESTIMATES.  THE 1ST 3 (PolyCoeffs) ARE GENERALLY IRRELEVANT
  Param=[PolyCoeffs[0],PolyCoeffs[1],PolyCoeffs[2],NuShift,Dnu,VMR]
end

;************************************************************************************
;************************************************************************************
pro Minimize_H2O_Features,disk,IG_filename,SampleFileName
;
;ROUTINE TO MINIMIZE THE H2O STRUCTURE IN RECORDED SCANS
;READS A SUITE OF H2O TRANSMITTANCE MODELS.
;REMOVES H2O SIGNATURE FROM SPECTRA OF BOTH INFRAGOLD REFERENCE AND FIELD SAMPLE, BY
;  "NUDGING" THE MEASUREMENTS ON THE WAVENUMBER AXIS, AND MINIMIZING THE MEAN DEVIATION IN THE RATIO: MEAS/MODEL
;THE CURVED MEASUREMENT BASELINE IS ACCOUNTED FOR VIA A QUADRATIC FIT 
;THIS CORRECTION ALSO ADJUSTS FOR H2O VOL MIXING RATIO (VMR) DURING THE REFERENCE MEASUREMENT, AND APPLIES THIS TO SAMPLE SPECTRUM
;
;INPUT FILES ARE '<filename>_avg.txt' CREATED BY 'Average_Time_Resolved_Scans.pro'
;THE ROUTINE SAVES THE CORRECTED REFERENCE SPECTRUM AS '<Infragold_filename>_Corrected_Results.txt'
;AND THE CORRECTED RATIO SPECTRUM AS
;'<Sample_Filename>_Corrected_Results.txt'   
loadct, 39,/silent

;
common shared,kabsMatrix,MeasSpec,MeasWvnPts
;
;disk= 'C:\Users\Dave\'
;disk= '/arcturus/kuckert/AOTF/DATA/2013JUN06/'
;
;---
;SELECT THE INFRAGOLD REFERENCE SPECTRUM
;WE NEED THIS FIRST, IN ORDER TO GET THE DATA WAVENUMBER SET - FOR CREATING kabsMatrix
;FROM THIS WE GET THE FREQUENCY & WAVELENGTH LISTS (DO AN INITIAL READ TO GET Ndata)
;
hdr=''
;Data_path= '\EPSCoR_ASTID_Project\Breadboard_Evaluation_Sample_Measurements\Mar052011_SatAM_MCT_neg80C_TC8_All_Smpls\'
;Data_path= '\EPSCoR_ASTID_Project\Breadboard_Evaluation_Sample_Measurements\Mar_5_2011_Excerpts_GSFC_SRM81A\'
Data_path= '';'Desktop\H2O_Correction_Demo_Folder\'
;
;IG_filename= 'Infragold_3InAs_avg'
;IG_filename= 'Infragold_13MCT_avg'
;IG_filename= 'Infragold1_avg' ;OUTPUT FROM "Average_Time_Resolved_Scans.pro"
;
  Ndata=0
  close,1
  openr,1,disk + Data_path + IG_filename + '.txt' ;Read 1st time to get Ndata
  readf,1,hdr
  while not eof(1) do begin
    readf,1,hdr
    Ndata= Ndata + 1
  endwhile
  close,1
  print,'Ndata=',Ndata
  MeasFreqPts= fltarr(Ndata)
  MeasWvlPts= fltarr(Ndata)
  IG_Spec= fltarr(Ndata)
;
  openr,1,disk + Data_path + IG_filename + '.txt'  ;2nd time to get data
  readf,1,hdr
  for i= 0,Ndata-1 do begin  
    readf,1,fr,wv,value
    MeasFreqPts[i]= fr
    MeasWvlPts[i]= wv
    IG_Spec[i]= value
  endfor
  close,1
;
  MeasSpec= IG_Spec
;
;DATA WAVENMBR VECTOR IS CREATED FROM MeasWvlPts
  MeasWvnPts= 1.e4 / MeasWvlPts
;
;--------
;LOAD THE GAS CELL MODEL SUITE CONSISTING OF 15 FILES:
;10 CM GAS CELL WHICH APPROXIMATES THE PATH IN OUR INSTRUMENT
; ATMOSPHERE WITH H2O VOL. MIXING RATIOS (VMR)OF 0.010, 0.015 AND 0.020
;FOR WAVENUMBER RESOLUTIONS (Dnu) OF 10, 15 , 20, 25 AND 30 CM-1 FWHM 
;THIS MODEL SUITE IS RESAMPLED AT THE SWEEP WAVENUMBER POINTS (SEVERAL TIMES FINER), THEN STORED INTO AN Ndata X 5 X 3 CUBE, 
;
  TransCube= fltarr(Ndata,5,3) 
;
  ModelPath= '/arcturus/kuckert/AOTF/Analysis/GasCell_H2O_ModelSuite/'
;  
  FileNames=[['H2Otrans_2941_6061_Dnu10_VMR010.txt','H2Otrans_2941_6061_Dnu15_VMR010.txt',$
  'H2Otrans_2941_6061_Dnu20_VMR010.txt','H2Otrans_2941_6061_Dnu25_VMR010.txt',$
  'H2Otrans_2941_6061_Dnu30_VMR010.txt'],['H2Otrans_2941_6061_Dnu10_VMR015.txt',$
  'H2Otrans_2941_6061_Dnu15_VMR015.txt','H2Otrans_2941_6061_Dnu20_VMR015.txt',$
  'H2Otrans_2941_6061_Dnu25_VMR015.txt','H2Otrans_2941_6061_Dnu30_VMR015.txt'],$
  ['H2Otrans_2941_6061_Dnu10_VMR020.txt','H2Otrans_2941_6061_Dnu15_VMR020.txt',$
  'H2Otrans_2941_6061_Dnu20_VMR020.txt','H2Otrans_2941_6061_Dnu25_VMR020.txt',$
  'H2Otrans_2941_6061_Dnu30_VMR020.txt']]
;
  for k=0,2 do begin   ;VMR
    for j=0,4 do begin   ;Dnu
      close,1
      openr,1,ModelPath + FileNames[j,k]
      for ii=0,19 do readf,1,hdr  ;read away all of the header info
      Nrows=0  ;Do 1st read to get Nrows
      while not eof(1) do begin
        readf,1,hdr
        Nrows= Nrows + 1
      endwhile
      close,1
;
      Wavenmbrs= fltarr(Nrows) ;Then redefine the arrays, since Nrows is different for each H2O model file
      transVals= fltarr(Nrows)
;
      openr,1,ModelPath + FileNames[j,k]  ;Then open again & get data
      for ii=0,19 do readf,1,hdr  ;read away all of the header info
      for ii=0,Nrows-1 do begin
        readf,1,wv,trans
        Wavenmbrs[ii]= wv
        transVals[ii]= trans
      endfor
      close,1
 ;
 ;    Add the transmission vector to the cube. Again, we interpolate each model file at the "MeasWvnPts"
      TransCube[*,j,k]= interpol(transVals,Wavenmbrs,MeasWvnPts,/quadratic) 
    endfor
  endfor
;
;USE TransCube TO CREATE THE MATRIX OF ABSORPTION COEFFS kabsMatrix[Ndata,5], WHICH ALLOWS INTERPOLATION TO ANY H2O COLUMN ABUNDANCE.
  kabsMatrix= fltarr(Ndata,5)
  for jj=0,4 do begin  ;Outer loop over Dnu (resolution) options
    for kk= 0,Ndata-1 do begin
      result= linfit([0.010,0.015,0.020],-alog(TransCube[kk,jj,*]),yfit=yfit)
      kabsMatrix[kk,jj]= result[1]
    endfor
  endfor
  ZeroIndices= where(MeasWvnPts lt 2950.0 or MeasWvnPts gt 5800.0)   ;between 1.72 and 3.39 um
  kabsMatrix[ZeroIndices,*]=0.0
;
;DEFINE THE WAVENUMBER SET AROUND THE H2O FEATURES.
;THIS IS THE REGION USED FOR MINIMIZING THE ABSOLUTE DEVIATIONS BETWEEN MODEL AND SHIFTED DATA.
;THIS CAN BE TRICKY FOR SAMPLE REFLECTANCES WHERE H2O FEATURES LIE ON THE WING OF A DEEP HYDRATION BAND 
  ROI_wvns= [3700.0,3900.0] ;cm-1     2.53-2.66 um    ;The H2O "NULL" REGION.  YOU CAN PLAY AROUND WITH THESE LIMITS
  fitIndices= where(MeasWvnPts gt min(ROI_wvns) and MeasWvnPts lt max(ROI_wvns),count)
  WvnSubSet= MeasWvnPts[fitIndices]
;  
;---------
;CORRECT THE INFRAGOLD REFERENCE
;
;THE ROUTINE "GetParam" DOES MOST OF THE WORK. IT RELIES ON THE FACT THAT THE UNKNOWN "nushift" AND H2O VOLUME MIXING RATIO
;ARE INDEPENDENT.
;"param" IS A 6 PARAMETER SET CONSISTING OF 3 POLYFIT (QUADRATIC) COEFFICIENTS, nushift (i.e. NUSHIFT), Dnu (the "fixed" INSTRUMENT
; RESOLUTION)  AND VMR (H2O VOL. MIXING RATIO)
;"GetParam" DOES A SINGLE SWEEP (Nsolve=1) OR TWO SUCCESSIVE SWEEPS (Nsolve=2):
; THE FIRST FINDS THE "NUSHIFT" BETWEEN THE MEASURED SPECTRUM AND THE MODEL H2O SPECTRUM, BY RATIOING MEASUREMENT TO MODEL, AND THEN
; FINDING THE MINIMUM IN THE SUMMED VALUES OF MEAN DEVIATION.  THE CURVED BASELINE IN THE MEASUREMENTS IS FIRST REMOVED BY FITTING TO A QUADRATIC.
; "Nsolve=2" INVOKES A 2ND PASS; NUSHIFT IS NOW FIXED, AND "GetParam" SCANS VMR, LOOKING FOR A MEAN DEVIATION MINIMUM IN A SIMILAR WAY.
; 
; BOTH PARAMETERS (Nsolve=2) ARE RETRIEVED FROM THE INFRAGOLD REFLECTANCE SPECTRUM.
; FOR THE SAMPLE SPECTRUM, WHICH FOLLOWS, VMR IS NOW HELD FIXED AND ONLY NuSHIFT IS RETRIEVED
; 
; Initialize starting guesses for the parameters
     nuShift= 0.0   ;Only need a dummy value here.  This is found by GetParam "from scratch" using a nuShift search window 
     Dnu= 10.0 ; The "fixed" spectrometer resolution in cm-1.  Depends a bit on the most recent instrument alignment, then should be fixed in value at the 
;      H2O wavelength.  This can be fine-tuned, but is generally close to 10 cm-1
     VMR= 0.015 ;the starting approximation for H2O vol mixing ratio.  This estimate is needed going in.
;      It may (Nsolve=2) or may not (Nsolve=1) be updated.
     param= [0.0,0.0,0.0,nuShift,Dnu,VMR]  ; The 1st 3 elements are the quadratic coeffs used to fit the meas baseline.
;      Dummy values only. No initial guesses needed. These are Updated continuously & generally not important.
;
;OK, SO LETS CORRECT THE INFRAGOLD REFERENCE
  Nsolve=2 
  GetParam,WvnSubSet,param,Nsolve  ;Nsolve=2 means we also solve for VMR.
;
; THE RETURNED PARAMETERS DEFINE THE BEST H2O MODEL WITH WHICH TO RATIO THE SPECTRUM 
    nuShift= param[3]
    Dnu= param[4]
    VMR= param[5]
;   CREATE THE H2O NULLED INFRAGOLD REFLECTANCE SPECTRUM USING THE RETURNED NuShift AND VMR PARAMETERS

    IG_Spec= interpol(MeasSpec,MeasWvnPts,MeasWvnPts+nuShift);  THE CORRECTLY SHIFTED MEASUREMENT USING THE NuShift RESULT 
    H2O_SpecSyn,MeasWvnPts,Dnu,VMR,H2O_Model ;THEN THE H2O MODEL (THE DENOMINATOR) AT ABOUT THE RIGHT Dnu AND VMR   
;
;DISPLAY THE nuShifted SPEC AND OVERLAY THE H2O NULLED SPEC
   window,7,xsize=1000,ysize=500,title= 'H2O Nulled Infragold spectrum'
   plot,MeasWvnPts,IG_Spec,xstyle=1,xrange=[min(MeasWvnPts),max(MeasWvnPts)],yrange= [0.0,1.05*max(IG_Spec)] ;First plot the shiftd spec
   IG_Nulled= IG_Spec/H2O_Model
   oplot,MeasWvnPts,IG_Nulled,color=240
   oplot,MeasWvnPts,0.15*H2O_Model  ;OVERLAY THE H2O SPECTRUM ITSELF TO SEE WHERE THE ADJUSTMENTS ARE
;
;ONE MORE STEP BEFORE SAVING THE H2O-NULLED REFERENCE SPECTRUM:
;SINCE THE MEASUREMENT WAVENUMBERS ARE NUDGED PLUS OR MINUS,
;  WE NEED TO RESAMPLE ALL SPECTRA ONTO A COMMON WAVELENGTH SCALE.
;WE CHOOSE 2740 -> 6450  AT 1 CM STEPS  (CORRESPONDING TO 3.65->1.55 MICRONS)
;
Nresampled= 3711
ResampledWvns= 2740.0 + findgen(Nresampled)  ;2740 to 6450 INCLUSIVE
IG_Spec_Resampled= interpol(IG_Spec,MeasWvnPts,ResampledWvns,/lsquadratic)
H2O_Model_Resampled= interpol(H2O_Model,MeasWvnPts,ResampledWvns,/lsquadratic)
IG_Nulled_Resampled= interpol(IG_Nulled,MeasWvnPts,ResampledWvns,/lsquadratic)
;
;THEN OUTPUT THE CORRECTED INFRAGOLD SPECTRUM
  close,1   
  openw,1,disk + Data_path + IG_filename + '_Corrected_Results.txt'
  printf,1,'Infragold - Data, Corrected, Resampled on Common Wavenumber Scale'
  printf,1,''
  printf,1,'nushift=',nushift,'  cm-1'
  printf,1,'FWHM_resolution:',Dnu,'  cm-1'
  printf,1,'H2O_Vol_mixing_ratio:',VMR
  printf,1,''
  printf,1,'     Wvnmbr     Wvl(um)     SpecData     H2O_Model    Nulled'
  for i=0,Nresampled-1 do printf,1,ResampledWvns[i],1.e4/ResampledWvns[i],IG_Spec_Resampled[i], H2O_Model_Resampled[i],IG_Nulled_Resampled[i],format='(f12.3,f10.5,3(2x,e12.4))'
  close,1
;
;
;-----------------------------------------------------
;NOW FOR THE SAMPLE:
;WE REPEAT THE PROCESS, AND THE CORRECTED SAMPLE IS DIVIDED BY THE CORRECTED REFERENCE
;**THE SAMPLE CAN BE TRICKY AS COMMENTED ABOVE, SINCE SNR IS GENERALLY LOWER, AND THE POLYFIT CAN BE UNSTABLE ON THE WING OF THE HYDRATION BAND
   ;SampleFileName= 'Anhydrite_avg'  
;SampleFileName= 'GSFC_SRM81A_Pyrene_2_MCT_avg'
;SampleFileName= 'GSFC_SRM81A_2_MCT_avg'
;SampleFileName= 'GSFC_SRM81A_Pyrene_2_InAs_avg'
;SampleFileName= 'GSFC_Basalt_7p0_avg'
;
;Read the sample data file
  Spec= fltarr(Ndata)
  openr,1,disk + Data_path + SampleFileName +'.txt' ;Get data
    readf,1,hdr
    for i= 0,Ndata-1 do begin
      readf,1,fr,wvl,value  ;fr & wvl not used here
      Spec[i]= value
    endfor
  close,1
;
  MeasSpec= Spec   ;MeasSpec is in Common block- updated here
;
  Nsolve=1  ;just nuShift; leave VMR as is
  GetParam,WvnSubSet,param,Nsolve  ;Uses "MeasSpec" in common block. Results of the prior fit make good initial guesses
     NuShift= param[3]
     Dnu= param[4]
     VMR= param[5]
     H2O_SpecSyn,MeasWvnPts,Dnu,VMR,H2O_Model ;
     Spec= interpol(MeasSpec,MeasWvnPts,MeasWvnPts+NuShift)  
;
window,7,xsize=1000,ysize=500,title= 'Display nulled model- Sample'
plot,MeasWvnPts,Spec,xstyle=1,xrange=[min(MeasWvnPts),max(MeasWvnPts)],yrange= [0.0,1.05*max(Spec)] ;First plot the shiftd spec
NulledSpec= Spec/H2O_Model
oplot,MeasWvnPts,NulledSpec,color=240
;
RatioSpec= NulledSpec / IG_Nulled
;
window,8,xsize=1000,ysize=500,title= 'Display Sample / Infragold'
plot,MeasWvlPts,RatioSpec,xstyle=1,xrange=[min(MeasWvlPts),max(MeasWvlPts)],yrange= [0.0,1.05*max(RatioSpec)] ;First plot the shiftd spec
;
;AND THE LAST STEP BEFORE SAVING
;PUT ALL SPECTRA ONTO THE COMMON WAVELENGTH SCALE.
; 2740 -> 6450  AT 1 CM STEPS  (CORRESPONDING TO 3.65->1.55 MICRONS)
;
Spec_Resampled= interpol(Spec,MeasWvnPts,ResampledWvns,/lsquadratic)
H2O_Model_Resampled= interpol(H2O_Model,MeasWvnPts,ResampledWvns,/lsquadratic)
NulledSpec_Resampled= interpol(NulledSpec,MeasWvnPts,ResampledWvns,/lsquadratic)
Ratio_Resampled= NulledSpec_Resampled / IG_Nulled_Resampled
;
;SAVE THE UNCORRECTED, CORRECTED AND SMOOTHED FILES
  close,1
  openw,1,disk + Data_path + SampleFileName + '_Corrected_Results.txt'
  printf,1,SampleFileName + ' - Data, Corrected, Resampled on common wavenumber scale'
  printf,1,''
  printf,1,'nushift=',nushift,'  cm-1'
  printf,1,'FWHM_resolution:',Dnu,'  cm-1'
  printf,1,'H2O_Vol_mixing_ratio:',VMR
  printf,1,''
  printf,1,'     Wvnmbr     Wvl(um)    SpecData    H2O_Model    NulledSpec     IG_Nulled     Ratio'
  for i=0,Nresampled-1 do printf,1,ResampledWvns[i],1.e4/ResampledWvns[i],Spec_Resampled[i],$
     H2O_Model_Resampled[i],NulledSpec_Resampled[i],IG_Nulled_Resampled[i],Ratio_Resampled[i],$
     format='(f12.3,f10.5,5(2x,e12.4))'
  close,1
;
END

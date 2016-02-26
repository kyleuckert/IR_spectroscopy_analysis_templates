pro IR_main
;examples of older analysis is available seperately (kuckert@nmsu.edu)

;#########################################################
;define paths
;data and bias path
data_path = 'data/samples/'
;Infragold path
IG_path = 'data/Infragold/'

;########################################################
;define data filelist
;AOTF IR spectrometer benchtop (2012 and later)
;these data are already corrected for H2O absorption using Glenar's IDL program
sample_filenames_H2O_corr = [data_path+'Geothite_avg_Corrected_Results.txt']

;data from GSFC AOTF, comma seperated .txt files (2012 and later)
;wavelength, reflectance
;samples are already Infragold calibrated
sample_filenames_GSFC_comma = [data_path+'gypsum_vacuum_1_day.txt', data_path+'gypsum_vacuum_5days.txt']

;data from GSFC AOTF, tab separated .txt files (2012 and later)
;wavelength		reflectance
;samples are already Infragold calibrated
sample_filenames_GSFC_no_comma = [data_path+'epsomite_powder.txt']

;GSFC AOTF .fit files (2012 and later, current format)
sample_filenames_fits = [data_path+'Jarosite_avg.fit', data_path+'Gypsum.fit']
IG_filenames_fits = [IG_path+'jarosite_IG.fit', IG_path+'Infragold.fit']

;PASA cashbox .csv (tuning curve for wavelength) (2013)
;these files have unreliable wavelength data, use tuning_curve_2013SEP16.txt or extract Poly terms
sample_filenames_csv_tuning_curve = [data_path+'FS050_jagged_no_board_2_avereaged.csv']
IG_filenames_csv_tuning_curve = [IG_path+'13_09_10_sample_10_avereaged.csv']

;PASA cashbox .csv (2013)
sample_filenames_csv = [data_path+'Montmorillonite1_01_average.csv', data_path+'anhydrite_rock1_01_raw.csv', data_path+'FS117_raw.csv']
IG_filenames_csv = [IG_path+'Montmorillonite_IG.csv', IG_path+'14_09_23_InfraGold_2_raw.csv', IG_path + '13_10_31_InfraGold_7_raw.csv']

;PASA cashbox .csv with bad scans (2013)
sample_filenames_csv_bad_scans = [data_path+'cvl020_01_raw.csv', data_path+'cvl021_01_raw.csv', data_path+'cvl022_01_raw.csv', data_path + 'cvl031_yellow_01_raw.csv']
IG_filenames_csv_bad_scans = [IG_path+'13_12_19_InfraGold_4_raw.csv', IG_path+'13_12_19_InfraGold_4_raw.csv', IG_path+'13_12_19_InfraGold_4_raw.csv', IG_path + '13_12_20_InfraGold_4_raw.csv']

;PASA cashbox .txt (2014, and later, current format)
;large header
;line 11: wavelength
;line 12: frequency
;line 13-256: reflectance
sample_filenames_PASA_cashbox = [data_path+'FW203_orange_01_raw.txt']
IG_filenames_PASA_cashbox = [IG_path+'InfraGold_5_raw.txt']

;PASA-Lite .txt files (2015 and later, current format)
;large header
;line 11: wavelength
;line 12: frequency
;line 13-256: reflectance
sample_filenames_PASA_lite = [data_path+'Bentonite_01_10_raw.txt', data_path+'Kaolin_01_10_raw.txt']
IG_filenames_PASA_lite = [IG_path+'Bentonite_IG.txt', IG_path+'Kaolin_IG.txt']

;.asc files downloaded from USGS spectral library
;large header
;wavelength		reflectance		err
sample_filenames_USGS = [data_path+'illite_imt1.10996.asc', data_path+'saponite_sapca1.20002.asc']


;bias correction is not completed in this template
;bias frames are only relevant for dark samples (basalt, MnO2)
;collection of these files was not standard practice until Sep 2015
;see PASA analysis template for bias correction

;creat output directory, if it doesn't exist
outputdir = findfile('output/', count=count)
if (count eq 0) then begin
	file_mkdir, 'output'
endif

;#########################################################
;main body
;wavelength and reflectance arrays for each sample
total_files = n_elements(sample_filenames_H2O_corr) + n_elements(sample_filenames_GSFC_comma) + n_elements(sample_filenames_GSFC_no_comma) + n_elements(sample_filenames_fits) + n_elements(sample_filenames_csv_tuning_curve) + n_elements(sample_filenames_csv) + n_elements(sample_filenames_csv_bad_scans) + n_elements(sample_filenames_PASA_cashbox) + n_elements(sample_filenames_PASA_lite) + n_elements(sample_filenames_USGS)
;file_count
k=0
wavelength = fltarr(total_files, 3000)
reflectance = fltarr(total_files, 3000)
;bias data for each sample
;no bias frames collected
;bias_reflectance = fltarr(n_elements(sample_filenames), 3000)
;bias corrected data with N keys (reflectance only for each sample)
;corr_reflectance = fltarr(n_elements(sample_filenames), 3000)
;array of file names
key=strarr(total_files)

;read all data
;divide data by Infragold file
;subtract bias file (bias files are also Infragold calibrated)


;AOTF IR spectrometer benchtop (2012 and later)
for i=0, n_elements(sample_filenames_H2O_corr)-1 do begin
	;define key based on file name
	split_position = (strsplit(sample_filenames_H2O_corr[i], 'samples/', /regex))[1]
	key[k] = strmid(sample_filenames_H2O_corr[i], split_position, strlen(sample_filenames_H2O_corr[i])-split_position-4)
	;read data
	readcol, sample_filenames_H2O_corr[i], wvnm, wvln, spec, wtr, nul, IGnul, refl, format='d,d,d,d,d,d,d'
	;part of the spectrum is cut off here (need a better solution)
	for j=0, 2999 do begin
		wavelength[k,j] = wvln[j]
	endfor
	for j=0, 2999 do begin
		reflectance[k,j] = refl[j]
	endfor
	print, 'finished reading file: ', key[k]
	;increment counter
	k=k+1
endfor

;data from GSFC AOTF, comma seperated .txt files (2012 and later)
for i=0, n_elements(sample_filenames_GSFC_comma)-1 do begin
	;define key based on file name
	split_position = (strsplit(sample_filenames_GSFC_comma[i], 'samples/', /regex))[1]
	key[k] = strmid(sample_filenames_GSFC_comma[i], split_position, strlen(sample_filenames_GSFC_comma[i])-split_position-4)
	;read data
	readcol, sample_filenames_GSFC_comma[i], wvln, refl, format='d,d'
	for j=0, n_elements(wvln)-1 do begin
		wavelength[k,j] = wvln[j]
	endfor
	wavelength[k,j:*]=999
	for j=0, n_elements(refl)-1 do begin
		reflectance[k,j] = refl[j]
	endfor
	print, 'finished reading file: ', key[k]
	;increment counter
	k=k+1
endfor

;data from GSFC AOTF, tab separated .txt files (2012 and later)
for i=0, n_elements(sample_filenames_GSFC_no_comma)-1 do begin
	;define key based on file name
	split_position = (strsplit(sample_filenames_GSFC_no_comma[i], 'samples/', /regex))[1]
	key[k] = strmid(sample_filenames_GSFC_no_comma[i], split_position, strlen(sample_filenames_GSFC_no_comma[i])-split_position-4)
	;read data
	readcol, sample_filenames_GSFC_no_comma[i], wvln, refl, format='d,d'
	for j=0, n_elements(wvln)-1 do begin
		wavelength[k,j] = wvln[j]
	endfor
	for j=0, n_elements(refl)-1 do begin
		reflectance[k,j] = refl[j]
	endfor
	print, 'finished reading file: ', key[k]
	;increment counter
	k=k+1
endfor

;GSFC AOTF .fit files (2012 and later, current format)
for i=0, n_elements(sample_filenames_fits)-1 do begin
	;define key based on file name
	split_position = (strsplit(sample_filenames_fits[i], 'samples/', /regex))[1]
	key[k] = strmid(sample_filenames_fits[i], split_position, strlen(sample_filenames_fits[i])-split_position-4)
	;read data
		
	refl_temp = readfits(sample_filenames_fits[i])
	refl_IG = readfits(IG_filenames_fits[i])
	for j=0, n_elements(refl_temp)-1 do begin
		reflectance[k,j]=refl_temp[j]/refl_IG[j]
	endfor
	;wavelength stored in tuning curve
	readcol,'data/Wavelength_SamplePoint_V2.txt', wvnm, wvln,format='d,d'
	for j=0, n_elements(wvln)-1 do begin
		wavelength[k,j] = wvln[j]
	endfor
	;alternatively...
	;wavenumber = 2621.5+(4.32*(findgen(n_elements(refl_temp))))
	;for j=0, n_elements(wavenumber)-1 do begin
		;wavelength[k,j] = (1E4/wavenumber[j])
	;endfor

	print, 'finished reading file: ', key[k]
	;increment counter
	k=k+1
endfor

;PASA cashbox .csv (tuning curve for wavelength) (2013)
for i=0, n_elements(sample_filenames_csv_tuning_curve)-1 do begin
	;define key based on file name
	split_position = (strsplit(sample_filenames_csv_tuning_curve[i], 'samples/', /regex))[1]
	key[k] = strmid(sample_filenames_csv_tuning_curve[i], split_position, strlen(sample_filenames_csv_tuning_curve[i])-split_position-4)
	;obtain Infragold calibrated data
	reflectance[k,*] = calibrate_csv_data(sample_filenames_csv_tuning_curve[i], IG_filenames_csv_tuning_curve[i])
	wavelength[k,*] = read_csv_file(sample_filenames_csv_tuning_curve[i], 0)
	;wavelength array for FSC May 2013 data is multiplied by E+14 for some reason...
	wavelength[k,*]=wavelength[k,*]/1E14

	;###########################################################
	;comment these next lines out if you are not using bias correction
	;obtain Infragold calibrated bias files
	;bias_reflectance[i,*] = calibrate_csv_data(bias_filenames[i], IG_filenames[i])
	;bias correction
	;corr_reflectance[i,*] = bias_correct(reflectance[i,*], bias_reflectance[i,*])
	
	print, 'finished reading file: ', key[k]
	k=k+1
endfor

;PASA cashbox .csv (2013)
for i=0, n_elements(sample_filenames_csv)-1 do begin
	;define key based on file name
	split_position = (strsplit(sample_filenames_csv[i], 'samples/', /regex))[1]
	key[k] = strmid(sample_filenames_csv[i], split_position, strlen(sample_filenames_csv[i])-split_position-4)
	;obtain Infragold calibrated data
	reflectance[k,*] = calibrate_csv_data(sample_filenames_csv[i], IG_filenames_csv[i])
	wavelength[k,*] = read_csv_file(sample_filenames_csv[i], 0)

	;###########################################################
	;comment these next lines out if you are not using bias correction
	;obtain Infragold calibrated bias files
	;bias_reflectance[i,*] = calibrate_csv_data(bias_filenames[i], IG_filenames[i])
	;bias correction
	;corr_reflectance[i,*] = bias_correct(reflectance[i,*], bias_reflectance[i,*])
	
	print, 'finished reading file: ', key[k]
	k=k+1
endfor

;PASA cashbox .csv with bad scans (2013)
for i=0, n_elements(sample_filenames_csv_bad_scans)-1 do begin
	;define key based on file name
	split_position = (strsplit(sample_filenames_csv_bad_scans[i], 'samples/', /regex))[1]
	key[k] = strmid(sample_filenames_csv_bad_scans[i], split_position, strlen(sample_filenames_csv_bad_scans[i])-split_position-4)
	;obtain Infragold calibrated data
	;if the data contains some bad scans, use the following:
	;integer represents scans to throw out (out of 256)
	reflectance[k,*] = calibrate_csv_data_bad_scans(sample_filenames_csv_bad_scans[i], IG_filenames_csv_bad_scans[i], 32)
	wavelength[k,*] = read_csv_file(sample_filenames_csv_bad_scans[i], 0)

	;###########################################################
	;comment these next lines out if you are not using bias correction
	;obtain Infragold calibrated bias files
	;bias_reflectance[i,*] = calibrate_csv_data(bias_filenames[i], IG_filenames[i])
	;bias correction
	;corr_reflectance[i,*] = bias_correct(reflectance[i,*], bias_reflectance[i,*])
	
	print, 'finished reading file: ', key[k]
	print, '(removed bad scans)'
	k=k+1
endfor

;PASA cashbox .txt (2014, and later, current format)
for i=0, n_elements(sample_filenames_PASA_cashbox)-1 do begin
	;define key based on file name
	split_position = (strsplit(sample_filenames_PASA_cashbox[i], 'samples/', /regex))[1]
	key[k] = strmid(sample_filenames_PASA_cashbox[i], split_position, strlen(sample_filenames_PASA_cashbox[i])-split_position-4)
	;obtain Infragold calibrated data
	reflectance[k,*] = calibrate_txt_data(sample_filenames_PASA_cashbox[i], IG_filenames_PASA_cashbox[i])
	wave_temp = read_txt_file(sample_filenames_PASA_cashbox[i], 0)
	for j=0, n_elements(wave_temp)-1 do begin
		wavelength[k,j]=wave_temp[j]
	endfor

	;###########################################################
	;comment these next lines out if you are not using bias correction
	;obtain Infragold calibrated bias files
	;bias_reflectance[i,*] = calibrate_txt_data(bias_filenames[i], IG_filenames[i])
	;bias correction
	;corr_reflectance[i,*] = bias_correct(reflectance[i,*], bias_reflectance[i,*])
	
	print, 'finished reading file: ', key[k]
	k=k+1
endfor

;PASA-Lite .txt files (2015 and later, current format)
for i=0, n_elements(sample_filenames_PASA_lite)-1 do begin
	;define key based on file name
	split_position = (strsplit(sample_filenames_PASA_lite[i], 'samples/', /regex))[1]
	key[k] = strmid(sample_filenames_PASA_lite[i], split_position, strlen(sample_filenames_PASA_lite[i])-split_position-4)
	;obtain Infragold calibrated data
	reflectance[k,*] = calibrate_txt_data(sample_filenames_PASA_lite[i], IG_filenames_PASA_lite[i])
	wave_temp = read_txt_file(sample_filenames_PASA_lite[i], 0)
	for j=0, n_elements(wave_temp)-1 do begin
		wavelength[k,j]=wave_temp[j]
	endfor
	
	;###########################################################
	;comment these next lines out if you are not using bias correction
	;obtain Infragold calibrated bias files
	;bias_reflectance[i,*] = calibrate_txt_data(bias_filenames[i], IG_filenames[i])
	;bias correction
	;corr_reflectance[i,*] = bias_correct(reflectance[i,*], bias_reflectance[i,*])
	
	print, 'finished reading file: ', key[k]
	k=k+1
endfor


;.asc files downloaded from USGS spectral library
for i=0, n_elements(sample_filenames_USGS)-1 do begin
	;define key based on file name
	split_position = (strsplit(sample_filenames_USGS[i], 'samples/', /regex))[1]
	key[k] = strmid(sample_filenames_USGS[i], split_position, strlen(sample_filenames_USGS[i])-split_position-4)
	;read data
	readcol, sample_filenames_USGS[i], wvln, refl, err, format='d,d,d'
	for j=0,2999 do begin
		wavelength[k,j] = wvln[j]
	endfor
	for j=0, 2999 do begin
		reflectance[k,j] = refl[j]
	endfor
	print, 'finished reading file: ', key[k]
	k=k+1
endfor

print, 'plotting...'

;#########################################################
;plot IR spectra

;example of a single spectrum plot
;(wavelength, reflectance, title, save file, smoothing integer)
;x-range cannot be modified - wavenumber scaling is not a linear function of wavelength
;###########################################################
;replace "corr_reflectance" with "reflectance" if not using bias correction

;Goethite
wavelength_plot=wavelength[where(key eq 'Geothite_avg_Corrected_Results'),*]
reflectance_plot=reflectance[where(key eq 'Geothite_avg_Corrected_Results'),*]

fig = IR_plot_spectrum(wavelength_plot, reflectance_plot, '', 'output/Goethite.eps', 2)

;example of multiple spectra (2) plot
;([wavelength1, wavelength2, ...], [reflectance1, reflectance2, ...], title, save file, legend, smoothing integer, trace color)
wavelength_plot=[wavelength[where(key eq 'gypsum_vacuum_1_day'),*], wavelength[where(key eq 'gypsum_vacuum_5days'),*]]
reflectance_plot=[reflectance[where(key eq 'gypsum_vacuum_1_day'),*], reflectance[where(key eq 'gypsum_vacuum_5days'),*]]

fig = IR_plot_spectra(wavelength_plot, reflectance_plot, '', 'output/gypsum_vacuum_comparison.eps', ['1 day in vacuum', '5 days in vacuum'], 2, [0, 254])

;epsomite
wavelength_plot=wavelength[where(key eq 'epsomite_powder'),*]
reflectance_plot=reflectance[where(key eq 'epsomite_powder'),*]

fig = IR_plot_spectrum(wavelength_plot, reflectance_plot, '', 'output/epsomite_powder.eps', 2)

;jarosite
wavelength_plot=wavelength[where(key eq 'Jarosite_avg'),*]
reflectance_plot=reflectance[where(key eq 'Jarosite_avg'),*]

fig = IR_plot_spectrum(wavelength_plot, reflectance_plot, '', 'output/jarosite.eps', 2)

;FSC Gypsum
wavelength_plot=[wavelength[where(key eq 'FS050_jagged_no_board_2_avereaged'),*]]
reflectance_plot=[reflectance[where(key eq 'FS050_jagged_no_board_2_avereaged'),*]]

fig = IR_plot_spectrum(wavelength_plot, reflectance_plot, 'FS050: cashbox (no smoothing)', 'output/FS050.eps', 1)

;Montmorillonite
wavelength_plot=[wavelength[where(key eq 'Montmorillonite1_01_average'),*]]
reflectance_plot=[reflectance[where(key eq 'Montmorillonite1_01_average'),*]]

fig = IR_plot_spectrum(wavelength_plot, reflectance_plot, '', 'output/Montmorillonite.eps', 2)

;actinobacteria
wavelength_plot=[wavelength[where(key eq 'FW203_orange_01_raw'),*]]
reflectance_plot=[reflectance[where(key eq 'FW203_orange_01_raw'),*]]

fig = IR_plot_spectrum(wavelength_plot, reflectance_plot, 'FW203: cashbox (boxcar smooth size: 10)', 'output/FW203_cashbox_smooth.eps', 10)

;Bentonite
wavelength_plot=[wavelength[where(key eq 'Bentonite_01_10_raw'),*]]
reflectance_plot=[reflectance[where(key eq 'Bentonite_01_10_raw'),*]]

fig = IR_plot_spectrum(wavelength_plot, reflectance_plot, '', 'output/bentonite.eps', 2)

;Kaolin
wavelength_plot=[wavelength[where(key eq 'Kaolin_01_10_raw'),*]]
reflectance_plot=[reflectance[where(key eq 'Kaolin_01_10_raw'),*]]

fig = IR_plot_spectrum(wavelength_plot, reflectance_plot, '', 'output/kaolin.eps', 2)

;Illite
wavelength_plot=[wavelength[where(key eq 'illite_imt1.10996'),*]]
reflectance_plot=[reflectance[where(key eq 'illite_imt1.10996'),*]]

fig = IR_plot_spectrum(wavelength_plot, reflectance_plot, '', 'output/illite.eps', 2)

;saponite
wavelength_plot=[wavelength[where(key eq 'saponite_sapca1.20002'),*]]
reflectance_plot=[reflectance[where(key eq 'saponite_sapca1.20002'),*]]

fig = IR_plot_spectrum(wavelength_plot, reflectance_plot, '', 'output/saponite.eps', 2)

;CVL sulfur + gypsum
wavelength_plot=wavelength[where(key eq 'cvl031_yellow_01_raw'),*]
reflectance_plot=reflectance[where(key eq 'cvl031_yellow_01_raw'),*]

fig = IR_plot_spectrum(wavelength_plot, reflectance_plot, 'CVL031: cashbox (no smoothing)', 'output/CVL031.eps', 1)

;with smoothing
fig = IR_plot_spectrum(wavelength_plot, reflectance_plot, 'CVL031: cashbox (boxcar smooth size: 10)', 'output/CVL031_smooth.eps', 10)



;Ca sulfate comparison
wavelength_plot=[wavelength[where(key eq 'epsomite_powder'),*], wavelength[where(key eq 'Gypsum'),*], wavelength[where(key eq 'anhydrite_rock1_01_raw'),*]]
reflectance_plot=[21*reflectance[where(key eq 'epsomite_powder'),*], reflectance[where(key eq 'Gypsum'),*], 1.8*reflectance[where(key eq 'anhydrite_rock1_01_raw'),*]]

fig = IR_plot_spectra(wavelength_plot, reflectance_plot, '', 'output/Ca_sulfate_comparison.eps', ['epsomite', 'gypsum', 'anhydrite'], 10, [0, 70, 254])

;#########################################################
;to plot something maunally and add annotations:

;!p.font=0
!p.thick=8
!x.thick=8
!y.thick=8
!p.charsize=2.5
!p.charthick=4
!p.thick=2
!x.margin=[8.5,2.5]
;if including a title, change this:
;!y.margin=[3.5,6.5]
!y.margin=[3.5,3.5]

wavelength_plot=[wavelength[where(key eq 'epsomite_powder'),*], wavelength[where(key eq 'Gypsum'),*], wavelength[where(key eq 'anhydrite_rock1_01_raw'),*]]
reflectance_plot=[21*reflectance[where(key eq 'epsomite_powder'),*], reflectance[where(key eq 'Gypsum'),*], 1.8*reflectance[where(key eq 'anhydrite_rock1_01_raw'),*]]

;to edit the xrange
;x_range=[1.6,3.6]
;title of plot
title = ''
;name of the save file
save_file='output/Ca_sulfate_comparison_annotate.eps'
;smoothing integer (set to 1 for no smoothing)
smoothing_int=[8,8,16]
;offset (if you want to offset each plot vertically):
offset=[0.0, 0.0, 0.0]
;define list for trace colors
color = [0, 70, 254]

set_plot,'ps'
;define size of figure
device,filename=save_file,/encapsulate,xsize=8,ysize=6,/inches,/COURIER,/tt_font,font_size=8;,/portrait;, /landscape
device,/color,bits_per_pixel=8
;load color table
loadct, 39

;create dummy plot (no data is drawn)
;with title:
;plot, wavelength, reflectance, color=0, thick=2, xrange=[1.6,3.6], xstyle=1, title = title, xtitle='wavelength (!4l!Xm)',yrange = [0.0,0.25], ystyle=1,ytitle='Relectance (arbitrary units)', /nodata, xticklen=0.000001,yminor=4;, ytickv=[0,0.2,0.4,0.6,0.8,1.0]
;without title:
plot, wavelength_plot[0,*], reflectance_plot[0,*], color=0, thick=2, xrange=[1.6,3.6], xstyle=1, xtitle='wavelength (!4l!Xm)',yrange = [0.0,0.7], ystyle=1, ytitle='Relectance (arbitrary units)', xticklen=0.000001,yminor=4, /nodata;, ytickv=[0,0.2,0.4,0.6,0.8,1.0]

;define lower x axis (wavelength)
axis, xaxis=0, xrange=[1.6,3.6],xstyle=1;, xtickinterval=1000
;define upper x axis (wavenumber)
axis, xaxis=1, xticks=4, xtitle='wavenumber (cm!e-1!n)', xtickv=[1.66666,2,2.5,3.33333], xtickname=['6000', '5000', '4000', '3000'], xminor=4

;plot data
for i=0, n_elements(wavelength_plot[*,0])-1 do begin
	oplot, wavelength_plot[i,*], smooth(reflectance_plot[i,*], smoothing_int[i]) + offset[i], color=color[i], linestyle=0, thick=4
endfor

;annotations
;dashed vertical red line
;plots, [1.76,1.76],[0,0.3],color=254,linestyle=1,thick=8
vline, 1.95, color=254, linestyle=1, thick=8
;label
xyouts, 1.81, 0.1, 'H!D2!NO', color=0, charsize=2.25
vline, 2.48, color=254, linestyle=1, thick=8
xyouts, 2.51, 0.58, '-OH', color=0, charsize=2.25
vline, 2.8, color=254, linestyle=1, thick=8
xyouts, 2.91, 0.51, 'H!D2!NO', color=0, charsize=2.25
plots, [2.8, 3.05], [0.5, 0.5], color=254, linestyle=1, thick=4
vline, 3.1, color=254, linestyle=1, thick=8

xyouts, 1.63, 0.18, 'epsomite', color=0, charsize=2.25
xyouts, 1.63, 0.57, 'gypsum', color=70, charsize=2.25
xyouts, 1.63, 0.65, 'anhydrite', color=254, charsize=2.25

device,/close
set_plot,'x'


;gypsum star comparison
wavelength_plot=[wavelength[where(key eq 'FS050_jagged_no_board_2_avereaged'),*], wavelength[where(key eq 'FS117_raw'),*]]
reflectance_plot=[reflectance[where(key eq 'FS050_jagged_no_board_2_avereaged'),*], reflectance[where(key eq 'FS117_raw'),*]]

fig = IR_plot_spectra(wavelength_plot, reflectance_plot, 'Gypsum Star Comparison (no smoothing)', 'output/gypsum_star_comparison.eps', ['in lab', 'in situ'], 1, [0, 254])

;to edit the xrange
;x_range=[1.6,3.6]
;title of plot
title = ''
;name of the save file
save_file='output/gypsum_star_comparison_annotate.eps'
;smoothing integer (set to 1 for no smoothing)
smoothing_int=[8,16]
;offset (if you want to offset each plot vertically):
offset=[0.0, 0.0]
;define list for trace colors
color = [0, 254]

set_plot,'ps'
;define size of figure
device,filename=save_file,/encapsulate,xsize=8,ysize=6,/inches,/COURIER,/tt_font,font_size=8;,/portrait;, /landscape
device,/color,bits_per_pixel=8
;load color table
loadct, 39

;create dummy plot (no data is drawn)
;with title:
;plot, wavelength, reflectance, color=0, thick=2, xrange=[1.6,3.6], xstyle=1, title = title, xtitle='wavelength (!4l!Xm)',yrange = [0.0,0.25], ystyle=1,ytitle='Relectance (arbitrary units)', /nodata, xticklen=0.000001,yminor=4;, ytickv=[0,0.2,0.4,0.6,0.8,1.0]
;without title:
plot, wavelength_plot[0,*], reflectance_plot[0,*], color=0, thick=2, xrange=[1.6,3.6], xstyle=1, xtitle='wavelength (!4l!Xm)',yrange = [0.0,0.25], ystyle=1, ytitle='Relectance (arbitrary units)', xticklen=0.000001,yminor=4, /nodata;, ytickv=[0,0.2,0.4,0.6,0.8,1.0]

;define lower x axis (wavelength)
axis, xaxis=0, xrange=[1.6,3.6],xstyle=1;, xtickinterval=1000
;define upper x axis (wavenumber)
axis, xaxis=1, xticks=4, xtitle='wavenumber (cm!e-1!n)', xtickv=[1.66666,2,2.5,3.33333], xtickname=['6000', '5000', '4000', '3000'], xminor=4

;plot data
for i=0, n_elements(wavelength_plot[*,0])-1 do begin
	oplot, wavelength_plot[i,*], smooth(reflectance_plot[i,*], smoothing_int[i]) + offset[i], color=color[i], linestyle=0, thick=4
endfor

;annotations
;dashed vertical red line
;plots, [1.76,1.76],[0,0.3],color=254,linestyle=1,thick=8
vline, 1.76, color=254, linestyle=1, thick=8
;label
xyouts,  1.62, .05, 'H!D2!NO',color=0,charsize=2.25
vline, 1.95, color=254, linestyle=1, thick=8
xyouts, 1.97, 0.23, 'H!D2!NO', color=0, charsize=2.25
vline, 2.23, color=254, linestyle=1, thick=8
xyouts, 2.07, 0.18, 'H!D2!NO', color=0, charsize=2.25
vline, 2.285, color=254, linestyle=1, thick=8
xyouts, 2.30, 0.17, '-OH', color=0, charsize=2.25
vline, 2.5, color=254, linestyle=1, thick=8
xyouts, 2.51, 0.2, 'H!D2!NO', color=0, charsize=2.25
vline, 2.78, color=254, linestyle=1, thick=8
xyouts, 2.84, 0.1, 'H!D2!NO', color=0, charsize=2.25
plots, [2.8, 2.99], [0.09, 0.09], color=254, linestyle=1, thick=4
vline, 3.01, color=254, linestyle=1, thick=8
plots, [3.35, 3.5], [0.10, 0.10], color=254, linestyle=1, thick=4
xyouts,  3.37,.11, 'CH',color=0,charsize=2.25;1.75

xyouts, 1.65, 0.23, 'in situ', color=254, charsize=2.25
xyouts, 1.65, 0.15, 'in lab', color=0, charsize=2.25


device,/close
set_plot,'x'



;CVL bioverm pattern
wavelength_plot=[wavelength[where(key eq 'cvl020_01_raw'),*], wavelength[where(key eq 'cvl021_01_raw'),*], wavelength[where(key eq 'cvl022_01_raw'),*]]
reflectance_plot=[reflectance[where(key eq 'cvl020_01_raw'),*], reflectance[where(key eq 'cvl021_01_raw'),*], reflectance[where(key eq 'cvl022_01_raw'),*]]

;to edit the xrange
;x_range=[1.6,3.6]
;title of plot
title = ''
;name of the save file
save_file='output/bioverm.eps'
;smoothing integer (set to 1 for no smoothing)
smoothing_int=[8,8,16]
;offset (if you want to offset each plot vertically):
offset=[0.0, 0.0, 0.0]
;define list for trace colors
color = [0, 70, 254]

set_plot,'ps'
;define size of figure
device,filename=save_file,/encapsulate,xsize=8,ysize=6,/inches,/COURIER,/tt_font,font_size=8;,/portrait;, /landscape
device,/color,bits_per_pixel=8
;load color table
loadct, 39

;create dummy plot (no data is drawn)
;with title:
;plot, wavelength, reflectance, color=0, thick=2, xrange=[1.6,3.6], xstyle=1, title = title, xtitle='wavelength (!4l!Xm)',yrange = [0.0,0.25], ystyle=1,ytitle='Relectance (arbitrary units)', /nodata, xticklen=0.000001,yminor=4;, ytickv=[0,0.2,0.4,0.6,0.8,1.0]
;without title:
plot, wavelength_plot[0,*], reflectance_plot[0,*], color=0, thick=2, xrange=[1.6,3.6], xstyle=1, xtitle='wavelength (!4l!Xm)',yrange = [0.0,0.27], ystyle=1, ytitle='Relectance (arbitrary units)', xticklen=0.000001,yminor=4, /nodata;, ytickv=[0,0.2,0.4,0.6,0.8,1.0]

;define lower x axis (wavelength)
axis, xaxis=0, xrange=[1.6,3.6],xstyle=1;, xtickinterval=1000
;define upper x axis (wavenumber)
axis, xaxis=1, xticks=4, xtitle='wavenumber (cm!e-1!n)', xtickv=[1.66666,2,2.5,3.33333], xtickname=['6000', '5000', '4000', '3000'], xminor=4

;plot data
for i=0, n_elements(wavelength_plot[*,0])-1 do begin
	oplot, wavelength_plot[i,*], smooth(reflectance_plot[i,*], smoothing_int[i]) + offset[i], color=color[i], linestyle=0, thick=4
endfor

;annotations
vline, 1.78, color=254, linestyle=1, thick=8
xyouts,  1.63, .17, 'H!D2!NO',color=0,charsize=2.25
vline, 1.93, color=254, linestyle=1, thick=8
xyouts, 1.95, 0.2, 'H!D2!NO', color=0, charsize=2.25
vline, 2.1, color=254, linestyle=1, thick=8
xyouts, 2.11, 0.18, '-OH', color=0, charsize=2.25
vline, 2.35, color=254, linestyle=1, thick=8
xyouts, 2.36, 0.15, '-OH', color=0, charsize=2.25
vline, 2.51, color=254, linestyle=1, thick=8
xyouts, 2.53, 0.22, 'H!D2!NO', color=0, charsize=2.25
vline, 2.72, color=254, linestyle=1, thick=8
xyouts, 2.8, 0.13, 'H!D2!NO', color=0, charsize=2.25
plots, [2.74, 2.99], [0.12, 0.12], color=254, linestyle=1, thick=4
vline, 3.01, color=254, linestyle=1, thick=8

xyouts, 1.63, 0.255, 'host rock', color=0, charsize=2.25
xyouts, 1.63, 0.12, 'black', color=70, charsize=2.25
xyouts, 1.63, 0.11, 'bioverm', color=70, charsize=2.25
xyouts, 1.63, 0.06, 'brown', color=254, charsize=2.25
xyouts, 1.63, 0.05, 'bioverm', color=254, charsize=2.25



device,/close
set_plot,'x'





stop
end
pro IR_main
;this file currently only demonstrates ploting for PASA csv files
;I plan on added a demonstration of older data as well
;examples of older analysis is available seperately (kuckert@nmsu.edu)

;#########################################################
;define paths
;data and bias path
;data path to Fort Stanton Cave Samples
FSC_data_path = 'data/2013FSC/samples/'
;data path to Cueva de Villa Luz Samples
CVL_data_path = 'data/2013CVL/samples/'
;Infragold path
FSC_IG_path = 'data/2013FSC/Infragold/'
CVL_IG_path = 'data/2013CVL/Infragold/'

;########################################################
;define data filelist
sample_filenames = [FSC_data_path + 'FS050_jagged_no_board_2_avereaged.csv', FSC_data_path + 'FS117_raw.csv', CVL_data_path + 'cvl031_yellow_01_raw.csv']
;define Infragold filelist corresponding to data files
IG_filenames = [FSC_IG_path + '13_09_10_sample_10_avereaged.csv', FSC_IG_path + '13_10_31_InfraGold_7_raw.csv', CVL_IG_path + '13_12_20_InfraGold_4_raw.csv']

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
wavelength = fltarr(n_elements(sample_filenames), 3000)
reflectance = fltarr(n_elements(sample_filenames), 3000)
;bias data for each sample
;no bias frames collected
;bias_reflectance = fltarr(n_elements(sample_filenames), 3000)
;bias corrected data with N keys (reflectance only for each sample)
;corr_reflectance = fltarr(n_elements(sample_filenames), 3000)
;array of file names
key=strarr(n_elements(sample_filenames))

;read all data
;divide data by Infragold file
;subtract bias file (bias files are also Infragold calibrated)

;read first data file (no bad scans - raw data not available)
for i=0, n_elements(sample_filenames)-3 do begin
	;define key based on file name
	split_position = (strsplit(sample_filenames[i], 'samples/', /regex))[1]
	key[i] = strmid(sample_filenames[i], split_position, strlen(sample_filenames[i])-split_position-4)
	;obtain Infragold calibrated data
	reflectance[i,*] = calibrate_csv_data(sample_filenames[i], IG_filenames[i])
	wavelength[i,*] = read_csv_file(sample_filenames[i], 0)

	;###########################################################
	;comment these next lines out if you are not using bias correction
	;obtain Infragold calibrated bias files
	;bias_reflectance[i,*] = calibrate_csv_data(bias_filenames[i], IG_filenames[i])
	;bias correction
	;corr_reflectance[i,*] = bias_correct(reflectance[i,*], bias_reflectance[i,*])
	
	print, 'finished reading file: ', key[i]
endfor

;wavelength array for FSC May 2013 data is multiplied by E+14 for some reason...
wavelength[0,*]=wavelength[0,*]/1E14


;raw data, bad scans can be removed prior to averaging
for i=1, n_elements(sample_filenames)-1 do begin
	;define key based on file name
	split_position = (strsplit(sample_filenames[i], 'samples/', /regex))[1]
	key[i] = strmid(sample_filenames[i], split_position, strlen(sample_filenames[i])-split_position-4)
	;obtain Infragold calibrated data
	;reflectance[i,*] = calibrate_csv_data(sample_filenames[i], IG_filenames[i])
	;if the data contains some bad scans, use the following:
	;integer represents scans to throw out (out of 256)
	reflectance[i,*] = calibrate_csv_data_bad_scans(sample_filenames[i], IG_filenames[i], 32)
	wavelength[i,*] = read_csv_file(sample_filenames[i], 0)

	;###########################################################
	;comment these next lines out if you are not using bias correction
	;obtain Infragold calibrated bias files
	;bias_reflectance[i,*] = calibrate_csv_data(bias_filenames[i], IG_filenames[i])
	;bias correction
	;corr_reflectance[i,*] = bias_correct(reflectance[i,*], bias_reflectance[i,*])
	
	print, 'finished reading file: ', key[i]
	print, '(removed bad scans)'
endfor

print, 'plotting...'

;#########################################################
;plot IR spectra

;example of a single spectrum plot
;(wavelength, reflectance, title, save file, smoothing integer)
;x-range cannot be modified - wavenumber scaling is not a linear function of wavelength
;###########################################################
;replace "corr_reflectance" with "reflectance" if not use bias correction
wavelength_plot=wavelength[where(key eq 'cvl031_yellow_01_raw'),*]
reflectance_plot=reflectance[where(key eq 'cvl031_yellow_01_raw'),*]

fig = IR_plot_spectrum(wavelength_plot, reflectance_plot, 'CVL031: cashbox (no smoothing)', 'output/CVL031.eps', 1)

;with smoothing
fig = IR_plot_spectrum(wavelength_plot, reflectance_plot, 'CVL031: cashbox (boxcar smooth size: 10)', 'output/CVL031_smooth.eps', 10)

wavelength_plot=[wavelength[where(key eq 'FS050_jagged_no_board_2_avereaged'),*]]
reflectance_plot=[reflectance[where(key eq 'FS050_jagged_no_board_2_avereaged'),*]]

fig = IR_plot_spectrum(wavelength_plot, reflectance_plot, 'FS050: cashbox (no smoothing)', 'output/FS050.eps', 1)

;example of multiple spectra (2) plot
;([wavelength1, wavelength2, ...], [reflectance1, reflectance2, ...], title, save file, legend, smoothing integer, trace color)
wavelength_plot=[wavelength[where(key eq 'FS050_jagged_no_board_2_avereaged'),*], wavelength[where(key eq 'FS117_raw'),*]]
reflectance_plot=[reflectance[where(key eq 'FS050_jagged_no_board_2_avereaged'),*], reflectance[where(key eq 'FS117_raw'),*]]

fig = IR_plot_spectra(wavelength_plot, reflectance_plot, 'Gypsum Star Comparison (no smoothing)', 'output/gypsum_star_comparison.eps', ['in lab', 'in situ'], 1, [0, 254])


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

wavelength_plot=[wavelength[where(key eq 'FS050_jagged_no_board_2_avereaged'),*], wavelength[where(key eq 'FS117_raw'),*]]
reflectance_plot=[reflectance[where(key eq 'FS050_jagged_no_board_2_avereaged'),*], reflectance[where(key eq 'FS117_raw'),*]]

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

stop
end
pro IR_main

;#########################################################
;define paths
;data and bias path
;data path to Fort Windows Cave Samples
cashbox_data_path15 = 'data/2015SEP15/samples/cashbox_data/15_09_15_tests/'
PASAlite_data_path15 = 'data/2015SEP15/samples/PASA-lite_data/15_09_15_tests/'
;Infragold path
cashbox_IG_path15 = 'data/2015SEP15/Infragold/cashbox_Infragold/'
PASAlite_IG_path15 = 'data/2015SEP15/Infragold/PASA-lite_Infragold/'

;########################################################
;define data filelist
sample_filenames = [cashbox_data_path15+'FW203_orange_01_raw.txt', cashbox_data_path15+'FW205_dark_01_raw.txt', cashbox_data_path15+'FW205_white_01_raw.txt', cashbox_data_path15+'FW205_white_02_raw.txt', PASAlite_data_path15+'PL_FW205_dark_01_raw.txt', PASAlite_data_path15+'PL_FW205_white_01_raw.txt']
;define Infragold filelist corresponding to data files
IG_filenames = [cashbox_IG_path15+'InfraGold_5_raw.txt', cashbox_IG_path15+'InfraGold_7_raw.txt', cashbox_IG_path15+'InfraGold_7_raw.txt', cashbox_IG_path15+'InfraGold_7_raw.txt', PASAlite_IG_path15+'InfraGold_4_raw.txt', PASAlite_IG_path15+'InfraGold_4_raw.txt']

;define bias filelist corresponding to data files
;###########################################################
;comment this next line out if you are not using bias correction
bias_filenames = [cashbox_data_path15+'bias_01_raw.txt', cashbox_data_path15+'bias_03_raw.txt', cashbox_data_path15+'bias_03_raw.txt', cashbox_data_path15+'bias_03_raw.txt', PASAlite_data_path15+'bias_02_raw.txt', PASAlite_data_path15+'bias_02_raw.txt']

;creat output directory, if it doesn't exist
outputdir = findfile('output/', count=count)
if (count eq 0) then begin
	file_mkdir, 'output'
endif

;#########################################################
;main body
;wavelength and reflectance arrays for each sample
;wavelength array has fewer data points than reflectance array
wavelength = fltarr(n_elements(sample_filenames), 2000)
reflectance = fltarr(n_elements(sample_filenames), 3000)
;bias data for each sample
bias_reflectance = fltarr(n_elements(sample_filenames), 3000)
;bias corrected data with N keys (reflectance only for each sample)
corr_reflectance = fltarr(n_elements(sample_filenames), 3000)
;array of file names
key=strarr(n_elements(sample_filenames))

;read all data
;divide data by Infragold file
;subtract bias file (bias files are also Infragold calibrated)
for i=0, n_elements(sample_filenames)-1 do begin
	;define key based on file name
	split_position = (strsplit(sample_filenames[i], 'tests/', /regex))[1]
	key[i] = strmid(sample_filenames[i], split_position, strlen(sample_filenames[i])-split_position-4)
	;obtain Infragold calibrated data
	reflectance[i,*] = calibrate_txt_data(sample_filenames[i], IG_filenames[i])
	wavelength[i,*] = read_txt_file(sample_filenames[i], 0)

	;###########################################################
	;comment these next lines out if you are not using bias correction
	;obtain Infragold calibrated bias files
	bias_reflectance[i,*] = calibrate_txt_data(bias_filenames[i], IG_filenames[i])
	;bias correction
	corr_reflectance[i,*] = bias_correct(reflectance[i,*], bias_reflectance[i,*])
	
	print, 'finished reading file: ', key[i]
endfor

print, 'plotting...'

;#########################################################
;plot IR spectra

;Four Windows comparison
;example of a single spectrum plot
;(wavelength, reflectance, title, save file, smoothing integer)
;x-range cannot be modified - wavenumber scaling is not a linear function of wavelength
;###########################################################
;replace "corr_reflectance" with "reflectance" if not use bias correction
wavelength_plot=wavelength[where(key eq 'FW203_orange_01_raw'),*]
reflectance_plot=corr_reflectance[where(key eq 'FW203_orange_01_raw'),0:1999]

fig = IR_plot_spectrum(wavelength_plot, reflectance_plot, 'FW203: cashbox (no smoothing)', 'output/FW203_cashbox.eps', 1)

;with smoothing
fig = IR_plot_spectrum(wavelength_plot, reflectance_plot, 'FW203: cashbox (boxcar smooth size: 10)', 'output/FW203_cashbox.eps', 10)


;example of multiple spectra (2) plot
;([wavelength1, wavelength2, ...], [reflectance1, reflectance2, ...], title, save file, legend, smoothing integer, trace color)
wavelength_plot=[wavelength[where(key eq 'FW205_dark_01_raw'),*], wavelength[where(key eq 'FW205_white_01_raw'),*]]
reflectance_plot=[corr_reflectance[where(key eq 'FW205_dark_01_raw'),0:1999], corr_reflectance[where(key eq 'FW205_white_01_raw'),0:1999]]

fig = IR_plot_spectra(wavelength_plot, reflectance_plot, 'FW205 Comparison IR spectrum: cashbox (no smoothing)', 'output/FW205_cashbox.eps', ['dark', 'white'], 1, [0, 254])


;example of multiple spectra (2) plot
wavelength_plot=[wavelength[where(key eq 'PL_FW205_dark_01_raw'),*], wavelength[where(key eq 'PL_FW205_white_01_raw'),*]]
reflectance_plot=[corr_reflectance[where(key eq 'PL_FW205_dark_01_raw'),0:1999], corr_reflectance[where(key eq 'PL_FW205_white_01_raw'),0:1999]]

fig = IR_plot_spectra(wavelength_plot, reflectance_plot, 'FW205 Comparison IR spectrum: PASA-Lite (no smoothing)', 'output/FW205_PL.eps', ['dark', 'white'], 1, [0, 254])


;example of multiple spectra (4) plot
;compare FW205 cashbox, PASA-lite
wavelength_plot=[wavelength[where(key eq 'FW205_dark_01_raw'),*], wavelength[where(key eq 'FW205_white_01_raw'),*], wavelength[where(key eq 'PL_FW205_dark_01_raw'),*], wavelength[where(key eq 'PL_FW205_white_01_raw'),*]]
reflectance_plot=[corr_reflectance[where(key eq 'FW205_dark_01_raw'),0:1999], corr_reflectance[where(key eq 'FW205_white_01_raw'),0:1999], corr_reflectance[where(key eq 'PL_FW205_dark_01_raw'),0:1999], corr_reflectance[where(key eq 'PL_FW205_white_01_raw'),0:1999]]

fig = IR_plot_spectra(wavelength_plot, reflectance_plot, 'FW205 PASA-Lite Cashbox Comparison (no smoothing)', 'output/FW205_cashbox_PL.eps', ['cashbox dark', 'cashbox white', 'PASA-Lite dark', 'PASA-Lite white'], 1, [0, 70, 120, 254])



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

wavelength_plot = [wavelength[where(key eq 'PL_FW205_dark_01_raw'), *], wavelength[where(key eq 'PL_FW205_white_01_raw'), *]]

reflectance_plot=[corr_reflectance[where(key eq 'PL_FW205_dark_01_raw'), 0:1999], corr_reflectance[where(key eq 'PL_FW205_white_01_raw'), 0:1999]]

;to edit the xrange
;x_range=[1.6,3.6]
;title of plot
title = ''
;name of the save file
save_file='output/FW205_PL_smooth_annotate.eps'
;smoothing integer (set to 1 for no smoothing)
smoothing_int=[8,8]
;offset (if you want to offset each plot vertically):
offset=[0.01, 0.01]
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
plot, wavelength_plot[0,*], reflectance_plot[0,*], color=0, thick=2, xrange=[1.6,3.6], xstyle=1, xtitle='wavelength (!4l!Xm)',yrange = [-0.01,0.06], ystyle=1, ytitle='Relectance (arbitrary units)', xticklen=0.000001,yminor=4, /nodata;, ytickv=[0,0.2,0.4,0.6,0.8,1.0]

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
vline, 1.75, color=254, linestyle=1, thick=8
;label
xyouts,  1.62, .015, 'H!D2!NO',color=0,charsize=2.25
vline, 1.92, color=254, linestyle=1, thick=8
xyouts, 1.96, 0.005, 'H!D2!NO', color=0, charsize=2.25
vline, 2.5, color=254, linestyle=1, thick=8
xyouts, 2.37, 0.033, 'H!D2!NO', color=0, charsize=2.25
vline, 2.72, color=254, linestyle=1, thick=8
xyouts, 2.81, 0.032, 'H!D2!N0', color=0, charsize=2.25
;dashed horizontal line
plots, [2.74, 2.99], [0.03, 0.03], color=254, linestyle=1, thick=4
vline, 3.01, color=254, linestyle=1, thick=8
plots, [3.35, 3.55], [0.03, 0.03], color=254, linestyle=1, thick=4
xyouts, 3.37, 0.032, 'CH', color=0, charsize=2.25

xyouts, 1.70, 0.055, 'actinobacteria', color=254, charsize=2.25
xyouts, 1.65, 0.032, 'basalt', color=0, charsize=2.25

device,/close
set_plot,'x'


stop
end
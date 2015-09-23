#import relevant libraries
import IR_plot
import IR_analysis
import os
import numpy as np
import sys
#import operator

#########################################################
#define paths
#data and bias (dark fram) path
cashbox_data_path15 = '/Users/kyleuckert/Documents/Research/AOTF_IR_spectrometer/Data/2015SEP15/samples/cashbox_data/15_09_15_tests/'
PASAlite_data_path15 = '/Users/kyleuckert/Documents/Research/AOTF_IR_spectrometer/Data/2015SEP15/samples/PASA-lite_data/15_09_15_tests/'
#Infagold path
cashbox_IG_path15 = '/Users/kyleuckert/Documents/Research/AOTF_IR_spectrometer/Data/2015SEP15/Infragold/cashbox_Infragold/'
PASAlite_IG_path15 = '/Users/kyleuckert/Documents/Research/AOTF_IR_spectrometer/Data/2015SEP15/Infragold/PASA-lite_Infragold/'


#########################################################
#define data filelist
sample_filenames = [cashbox_data_path15+'FW203_orange_01_raw.txt', cashbox_data_path15+'FW205_dark_01_raw.txt', cashbox_data_path15+'FW205_white_01_raw.txt', cashbox_data_path15+'FW205_white_02_raw.txt', PASAlite_data_path15+'PL_FW205_dark_01_raw.txt', PASAlite_data_path15+'PL_FW205_white_01_raw.txt']
#define Infragold filelist corresponding to data files
IG_filenames = [cashbox_IG_path15+'InfraGold_5_raw.txt', cashbox_IG_path15+'InfraGold_7_raw.txt', cashbox_IG_path15+'InfraGold_7_raw.txt', cashbox_IG_path15+'InfraGold_7_raw.txt', PASAlite_IG_path15+'InfraGold_4_raw.txt', PASAlite_IG_path15+'InfraGold_4_raw.txt']

#define bias filelist corresponding to data files
bias_filenames = [cashbox_data_path15+'bias_01_raw.txt', cashbox_data_path15+'bias_03_raw.txt', cashbox_data_path15+'bias_03_raw.txt', cashbox_data_path15+'bias_03_raw.txt', PASAlite_data_path15+'bias_02_raw.txt', PASAlite_data_path15+'bias_02_raw.txt']


#########################################################
#main body
#dictionary with N*2 keys (wavelength and reflectance for each sample)
#where N is the number of data files
data = {}
#bias data with N keys (reflectance only for each sample)
data_bias = {}
#bias corrected data with N keys (reflectance only for each sample)
data_corr  ={}

#read all data
#divide data by Infragold file
#subtract bias file (bias files are also Infragold calibrated)
for index, file in enumerate(sample_filenames):
	#data stored in dictionary
	#define key based on file name
	key=file.split('tests/',1)[-1]
	key=key.rstrip('raw_.txt')
	#store wavelength and reflectance data in key
	data[key+'_wavelength']=[]
	data[key+'_reflectance']=[]
	data_bias[key+'_wavelength']=[]
	data_bias[key+'_reflectance']=[]
	data_corr[key+'_reflectance']=[]
	#obtain Infragold calibrated data
	data[key+'_wavelength'], data[key+'_reflectance'] = IR_analysis.calibrate_data(file, IG_filenames[index])

	#obtain Infragold calibrated bias files
	data_bias[key+'_wavelength'], data_bias[key+'_reflectance'] = IR_analysis.calibrate_data(bias_filenames[index], IG_filenames[index])
	#bias correction
	data_corr[key+'_reflectance'] = IR_analysis.bias_correct(data[key+'_reflectance'], data_bias[key+'_reflectance'])
	print key

	
#plot IR spectra
#Four Windows comparison
#example of a single spectrum plot
#wavelength, reflectance, xrange, title, save file, smoothing int
IR_plot.plot_IR_spectrum(np.array(data['FW203_orange_01_wavelength']), np.array(data_corr['FW203_orange_01_reflectance']), [1.6,3.6], 'FW201: cashbox (no smoothing)', 'FW203_cashbox.png', 1)

#with smoothing
IR_plot.plot_IR_spectrum(np.array(data['FW203_orange_01_wavelength']), np.array(data_corr['FW203_orange_01_reflectance']), [1.6,3.6], 'FW201: cashbox (boxcar smooth size: 10)', 'FW203_cashbox_smooth.png', 10)


#example of multiple spectra (2) plot
#[wavelength1, wavelength2, ...], [reflectance1, reflectance2, ...], xrange, title, save file, legend, smoothing int
IR_plot.plot_IR_spectra([np.array(data['FW205_dark_01_wavelength']), np.array(data['FW205_white_01_wavelength'])], [np.array(data_corr['FW205_dark_01_reflectance']), np.array(data_corr['FW205_white_01_reflectance'])], [1.6,3.6], 'FW205 Comparison IR spectrum: cashbox (no smoothing)', 'FW205_cashbox.png', ['dark', 'white'], 1)

#example of multiple spectra (2) plot
IR_plot.plot_IR_spectra([np.array(data['PL_FW205_dark_01_wavelength']), np.array(data['PL_FW205_white_01_wavelength'])], [np.array(data_corr['PL_FW205_dark_01_reflectance']), np.array(data_corr['PL_FW205_white_01_reflectance'])], [1.6,3.6], 'FW205 Comparison IR spectrum: PASA-Lite (no smoothing)', 'FW205_PL.png', ['dark', 'white'], 1)


#example of multiple spectra (4) plot
#compare FW205 cashbox, PASA-lite
IR_plot.plot_IR_spectra([np.array(data['FW205_dark_01_wavelength']), np.array(data['FW205_white_01_wavelength']), np.array(data['PL_FW205_dark_01_wavelength']), np.array(data['PL_FW205_white_01_wavelength'])], [np.array(data_corr['FW205_dark_01_reflectance']), np.array(data_corr['FW205_white_01_reflectance']), np.array(data_corr['PL_FW205_dark_01_reflectance']), np.array(data_corr['PL_FW205_white_01_reflectance'])], [1.6,3.6], 'FW205 PASA-Lite Cashbox Comparison (no smoothing)', 'FW205_cashbox_PL.png', ['cashbox dark', 'cashbox white', 'PASA-Lite dark', 'PASA-Lite white'], 1)


#this command will halt the program and safely exit
#sys.exit()	

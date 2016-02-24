#import relevant libraries
import IR_plot
import IR_analysis
import os
import numpy as np
import sys
#import operator
#if plotting within IR_main:
import matplotlib as mpl
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import pylab
from matplotlib import gridspec
from matplotlib.ticker import AutoMinorLocator


#########################################################
#define paths
#data and bias (dark frame) path
cashbox_data_path15 = 'data/2015SEP15/samples/cashbox_data/15_09_15_tests/'
PASAlite_data_path15 = 'data/2015SEP15/samples/PASA-lite_data/15_09_15_tests/'
#Infagold path
cashbox_IG_path15 = 'data/2015SEP15/Infragold/cashbox_Infragold/'
PASAlite_IG_path15 = 'data/2015SEP15/Infragold/PASA-lite_Infragold/'

#########################################################
#create ouput directory for figures, if it doesn't exist
if not os.path.exists('output'):
    os.makedirs('output')

#########################################################
#define data filelist
sample_filenames = [cashbox_data_path15+'FW203_orange_01_raw.txt', cashbox_data_path15+'FW205_dark_01_raw.txt', cashbox_data_path15+'FW205_white_01_raw.txt', cashbox_data_path15+'FW205_white_02_raw.txt', PASAlite_data_path15+'PL_FW205_dark_01_raw.txt', PASAlite_data_path15+'PL_FW205_white_01_raw.txt']
#define Infragold filelist corresponding to data files
IG_filenames = [cashbox_IG_path15+'InfraGold_5_raw.txt', cashbox_IG_path15+'InfraGold_7_raw.txt', cashbox_IG_path15+'InfraGold_7_raw.txt', cashbox_IG_path15+'InfraGold_7_raw.txt', PASAlite_IG_path15+'InfraGold_4_raw.txt', PASAlite_IG_path15+'InfraGold_4_raw.txt']

#define bias filelist corresponding to data files
###########################################################
#comment this next line out if you are not using bias correction
bias_filenames = [cashbox_data_path15+'bias_01_raw.txt', cashbox_data_path15+'bias_03_raw.txt', cashbox_data_path15+'bias_03_raw.txt', cashbox_data_path15+'bias_03_raw.txt', PASAlite_data_path15+'bias_02_raw.txt', PASAlite_data_path15+'bias_02_raw.txt']


#########################################################
#main body
#dictionary with N*2 keys (wavelength and reflectance for each sample)
#where N is the number of data files
data = {}
#bias data with N*2 keys (wavelength and reflectance for each sample)
data_bias = {}
#bias corrected data with N keys (reflectance only for each sample)
data_corr  ={}

#read all data
#divide data by Infragold file
#subtract bias file (bias files are also Infragold calibrated)
for index, file in enumerate(sample_filenames):
	#data is stored in dictionary
	#define key based on file name
	key=file.split('tests/',1)[-1]
	key=key.rstrip('raw_.txt')
	#store wavelength and reflectance data in key
	data[key+'_wavelength']=[]
	data[key+'_reflectance']=[]
	###########################################################
	#comment these next 2 lines out if you are not using bias correction
	data_bias[key+'_wavelength']=[]
	data_bias[key+'_reflectance']=[]
	data_corr[key+'_reflectance']=[]
	#obtain Infragold calibrated data
	data[key+'_wavelength'], data[key+'_reflectance'] = IR_analysis.calibrate_data(file, IG_filenames[index])

	#obtain Infragold calibrated bias files
	data_bias[key+'_wavelength'], data_bias[key+'_reflectance'] = IR_analysis.calibrate_data(bias_filenames[index], IG_filenames[index])
	#bias correction
	###########################################################
	#comment this next line out if you are not using bias correction
	data_corr[key+'_reflectance'] = IR_analysis.bias_correct(data[key+'_reflectance'], data_bias[key+'_reflectance'])
	print 'finished reading file: ', key


print 'plotting...'
#########################################################
#plot IR spectra
#Four Windows comparison
#example of a single spectrum plot
#(wavelength, reflectance, xrange, title, save file, smoothing integer)
###########################################################
#replace "data_corr" with "data" if not use bias correction
IR_plot.plot_IR_spectrum(np.array(data['FW203_orange_01_wavelength']), np.array(data_corr['FW203_orange_01_reflectance']), [1.6,3.6], 'FW201: cashbox (no smoothing)', 'output/FW203_cashbox.png', 1)

#with smoothing
IR_plot.plot_IR_spectrum(np.array(data['FW203_orange_01_wavelength']), np.array(data_corr['FW203_orange_01_reflectance']), [1.6,3.6], 'FW201: cashbox (boxcar smooth size: 10)', 'output/FW203_cashbox_smooth.png', 10)


#example of multiple spectra (2) plot
#([wavelength1, wavelength2, ...], [reflectance1, reflectance2, ...], xrange, title, save file, legend, smoothing integer)
IR_plot.plot_IR_spectra([np.array(data['FW205_dark_01_wavelength']), np.array(data['FW205_white_01_wavelength'])], [np.array(data_corr['FW205_dark_01_reflectance']), np.array(data_corr['FW205_white_01_reflectance'])], [1.6,3.6], 'FW205 Comparison IR spectrum: cashbox (no smoothing)', 'output/FW205_cashbox.png', ['dark', 'white'], 1)

#example of multiple spectra (2) plot
IR_plot.plot_IR_spectra([np.array(data['PL_FW205_dark_01_wavelength']), np.array(data['PL_FW205_white_01_wavelength'])], [np.array(data_corr['PL_FW205_dark_01_reflectance']), np.array(data_corr['PL_FW205_white_01_reflectance'])], [1.6,3.6], 'FW205 Comparison IR spectrum: PASA-Lite (no smoothing)', 'output/FW205_PL.png', ['dark', 'white'], 1)


#example of multiple spectra (4) plot
#compare FW205 cashbox, PASA-lite
IR_plot.plot_IR_spectra([np.array(data['FW205_dark_01_wavelength']), np.array(data['FW205_white_01_wavelength']), np.array(data['PL_FW205_dark_01_wavelength']), np.array(data['PL_FW205_white_01_wavelength'])], [np.array(data_corr['FW205_dark_01_reflectance']), np.array(data_corr['FW205_white_01_reflectance']), np.array(data_corr['PL_FW205_dark_01_reflectance']), np.array(data_corr['PL_FW205_white_01_reflectance'])], [1.6,3.6], 'FW205 PASA-Lite Cashbox Comparison (no smoothing)', 'output/FW205_cashbox_PL.png', ['cashbox dark', 'cashbox white', 'PASA-Lite dark', 'PASA-Lite white'], 1)



#########################################################
#to plot something maunally and add annotations:
#add wavelength data to this list
wavelength = [np.array(data['PL_FW205_dark_01_wavelength']), np.array(data['PL_FW205_white_01_wavelength'])]

#add reflectance data to this list
reflectance=[np.array(data_corr['PL_FW205_dark_01_reflectance']), np.array(data_corr['PL_FW205_white_01_reflectance'])]

#to edit the xrange
x_range=[1.6,3.6]
#name of the save file
save_file='output/FW205_PL_smooth_annotate.png'
#smoothing integer (set to 1 for no smoothing)
smooth=[8,8]
#offset (if you want to offset each plot vertically):
offset=[0.01, 0.01]

#sets up the plotting environment
fig = plt.figure()
fig.subplots_adjust(top=0.90)
ax1=fig.add_subplot(111)
ax2=ax1.twiny()
#plot multiple spectra

#define list for trace colors (k=black, -=solid line)
#see matplotlib documentation for plotting color/symbol options
color = ['k-', 'b-']

#plot each trace
for i, wave_temp in enumerate(wavelength):
	wave_temp=wavelength[i]
	reflectance_temp=reflectance[i]
	wave_tempT=wave_temp.T
	reflectance_tempT=reflectance_temp.T
	#only first 2000 points are relevant
	#first few points are nearly 0 (>3.7 microns, stretch y axes)
	reflectance_tempT=reflectance_tempT[10:2000]
	wave_tempT=wave_tempT[10:2000]

	#for valid mode
	ax1.plot(IR_plot.runningMeanFast(wave_tempT, smooth[i]), IR_plot.runningMeanFast(reflectance_tempT, smooth[i])+offset[i], color[i])


ax1.set_xlabel('Wavelength ($\mu$m)')
ax1.set_ylabel('Reflectance')
ax1.set_xlim(x_range)
#defines the y axis range
ax1.set_ylim([-0.01,0.06])
ax1.xaxis.set_minor_locator(AutoMinorLocator(5))
ax1.yaxis.set_minor_locator(AutoMinorLocator(2)) 

#annotations
#dashed vertical red line
ax1.axvline(1.75, color='r', linestyle='--')
#label
ax1.text(1.62, 0.015, 'H$_2$O', color='k')
ax1.axvline(1.92, color='r', linestyle='--')
ax1.text(1.96, 0.005, 'H$_2$O', color='k')
ax1.axvline(2.5, color='r', linestyle='--')
ax1.text(2.37, 0.033, 'H$_2$O', color='k')
ax1.axvline(2.72, color='r', linestyle='--')
ax1.text(2.81, 0.032, 'H$_2$O', color='k')
ax1.hlines(.03, 2.74, 2.99, color='r', linestyle='--')
ax1.axvline(3.01, color='r', linestyle='--')
ax1.hlines(0.03, 3.35, 3.55, color='r', linestyle='--')
ax1.text(3.37, 0.032, 'CH', color='k')

ax1.text(1.7, 0.056, 'actinobacteria', color='b')
ax1.text(1.65, 0.031, 'basalt')

#remove tick label and tick marks
ax2.xaxis.set_major_formatter(plt.NullFormatter())
ax2.xaxis.set_minor_formatter(plt.NullFormatter())
for tic in ax2.xaxis.get_major_ticks():
	tic.tick1On = tic.tick2On = False
	tic.label1On = tic.label2On = False

ax2=ax1.twiny()
ax2.set_xlabel('wavenumber (cm$^{-1}$)')
#array with values of tick mark locations
#wavenumber labels multiple of 1000 cm^-1
wavenumber_label=[]
wavenumber_location=[]
for loc in range(int(1+(1E4/x_range[0] - 1E4/x_range[1])/1000)):
	wavenumber=int((1E4/x_range[0]) - 1000*loc)/1000*1000
	wavenumber_label.append(wavenumber)
	location= 1 - ((x_range[1] - 1E4/wavenumber)/(x_range[1] - x_range[0]))
	wavenumber_location.append(location)

minor_locator=[]
num_minor=len(wavenumber_location)*3
for i in range(len(wavenumber_location)-1):
	diff=wavenumber_location[i+1]-wavenumber_location[i]
	for j in range(4):
		minor_locator.append((j+1) * (diff/4.0) + wavenumber_location[i])
	
ax2.set_xticks(wavenumber_location)
ax2.set_xticklabels(wavenumber_label)
ax2.xaxis.set_minor_locator(plt.FixedLocator(minor_locator))

pylab.savefig(save_file, dpi=200)
plt.clf()
plt.close(fig)




#this command will halt the program and safely exit
#sys.exit()	

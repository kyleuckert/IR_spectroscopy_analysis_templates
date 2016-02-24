#import relevant libraries
import IR_analysis
import IR_plot
import os
import numpy as np
import sys
import matplotlib as mpl
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import pylab
from matplotlib import gridspec
from matplotlib.ticker import AutoMinorLocator


#########################################################
#define paths
#gypsum
AOTFpathGSFC_gypsum='/Users/kyleuckert/Documents/Research/AOTF_IR_spectrometer/Data/2013GSFC_gypsum/'

#anhydrite
AOTFpath23='/Users/kyleuckert/Dropbox/Astrobiology/AOTF/DATA/2014SEP23/'

#epsomite
epsomite_data_path='/Users/kyleuckert/Documents/Research/AOTF_IR_spectrometer/Data/2014AUG_epsomite_tryp/'

#########################################################
#define data filelist
#gypsum
sample_filenames_gypsum_fit = [AOTFpathGSFC_gypsum+'Gypsum.fit']
IG_filenames_gypsum_fit = [AOTFpathGSFC_gypsum+'Infragold.fit']

sample_filenames_anhydrite_csv = [AOTFpath23+'samples/anhydrite_powder1_01_average.csv', AOTFpath23+'samples/anhydrite_rock1_01_average.csv']
IG_filenames_anhydrite_csv = [AOTFpath23+'Infragold/14_09_23_InfraGold_2_average.csv', AOTFpath23+'Infragold/14_09_23_InfraGold_2_average.csv']

sample_filenames_epsomite = [epsomite_data_path+'epsomite_powder/epsomite_powder.txt']


#########################################################
#main body
#dictionary with N*2 keys (wavelength and reflectance for each sample)
#where N is the number of data files
data = {}
#bias data with N keys (reflectance only for each sample)
#data_bias = {}
#bias corrected data with N keys (reflectance only for each sample)
#data_corr  ={}

#read all data
#divide data by Infragold file
#subtract bias file (bias files are also Infragold calibrated)

for index, file in enumerate(sample_filenames_epsomite):
	#data stored in dictionary
	#define key based on file name
	key=file.split('powder/',1)[-1]
	key=key.rstrip('.txt')
	#store wavelength and reflectance data in key
	data[key+'_wavelength']=[]
	data[key+'_reflectance']=[]
	#obtain Infragold calibrated data
	data[key+'_wavelength'], data[key+'_reflectance'] = IR_analysis.calibrate_data(file, 0)
	print 'finished reading file: ', key
	IR_analysis.write_file(key, data[key+'_wavelength'], data[key+'_reflectance'])
	
for index, file in enumerate(sample_filenames_gypsum_fit):
	#data stored in dictionary
	#define key based on file name
	key=file.split('2013GSFC_gypsum/',1)[-1]
	key=key.rstrip('.fit')
	#store wavelength and reflectance data in key
	data[key+'_wavelength']=[]
	data[key+'_reflectance']=[]
	#obtain Infragold calibrated data
	data[key+'_wavelength'], data[key+'_reflectance'] = IR_analysis.calibrate_data_fits(file, IG_filenames_gypsum_fit[index])
	print 'finished reading file: ', key
	IR_analysis.write_file(key, data[key+'_wavelength'], data[key+'_reflectance'])

	
for index, file in enumerate(sample_filenames_anhydrite_csv):
	#data stored in dictionary
	#define key based on file name
	key=file.split('samples/',1)[-1]
	key=key.rstrip('.csv')
	#store wavelength and reflectance data in key
	data[key+'_wavelength']=[]
	data[key+'_reflectance']=[]
	#obtain Infragold calibrated data
	data[key+'_wavelength'], data[key+'_reflectance'] = IR_analysis.calibrate_data_csv(file, IG_filenames_anhydrite_csv[index])
	print 'finished reading file: ', key
	IR_analysis.write_file(key, data[key+'_wavelength'], data[key+'_reflectance'])



#gypsum vacuum comparison
#IR_plot.plot_IR_spectra([np.array(data['gypsum_vacuum_1_day_wavelength']), np.array(data['gypsum_vacuum_5days_wavelength'])], [np.array(data['gypsum_vacuum_1_day_reflectance']), np.array(data['gypsum_vacuum_5days_reflectance'])], [1.6,3.6], ' ', 'gypsum_vacuum_comparison.png', ['1 day in vacuum', '5 days in vacuum'], 2)

#epsomite
#IR_plot.plot_IR_spectrum(np.array(data['epsomite_powder_wavelength']), np.array(data['epsomite_powder_reflectance']), [1.6,3.6], '', 'epsomite_powder.png', 2)

#gypsum
#IR_plot.plot_IR_spectrum(np.array(data['Gypsum_wavelength']), np.array(data['Gypsum_reflectance']), [1.6,3.6], '', 'Gypsum.png', 2)

#anhydrite rock
#IR_plot.plot_IR_spectrum(np.array(data['anhydrite_rock1_01_average_wavelength']), np.array(data['anhydrite_rock1_01_average_reflectance']), [1.6,3.6], '', 'anhydrite_rock.png', 2)


#Ca sulfate comparison
#IR_plot.plot_IR_spectra([np.array(data['epsomite_powder_wavelength']), np.array(data['Gypsum_wavelength']), np.array(data['anhydrite_rock1_01_average_wavelength'])], [21*np.array(data['epsomite_powder_reflectance']), np.array(data['Gypsum_reflectance']), 1.8*np.array(data['anhydrite_rock1_01_average_reflectance'])], [1.6,3.6], [0,0.7], ' ', 'Ca_sulfate_comparison.png', ['epsomite', 'gypsum', 'anhydrite'], 10)




wavelength = [np.array(data['epsomite_powder_wavelength']), np.array(data['Gypsum_wavelength']), np.array(data['anhydrite_rock1_01_average_wavelength'])]

reflectance = [21*np.array(data['epsomite_powder_reflectance']), np.array(data['Gypsum_reflectance']), 1.8*np.array(data['anhydrite_rock1_01_average_reflectance'])]

x_range=[1.6,3.6]
save_file='sulfate_comparison.png'
smooth=8

fig = plt.figure()
fig.subplots_adjust(top=0.90)
ax1=fig.add_subplot(111)
ax2=ax1.twiny()
#plot multiple spectra

wave_temp=wavelength[0]
reflectance_temp=reflectance[0]
wave_temp1=wave_temp.T
reflectance_temp1=reflectance_temp.T
#for valid mode
ax1.plot(IR_plot.runningMeanFast(wave_temp1, smooth), IR_plot.runningMeanFast(reflectance_temp1, smooth), 'k-')

wave_temp=wavelength[1]
reflectance_temp=reflectance[1]
wave_temp2=wave_temp.T
reflectance_temp2=reflectance_temp.T
#for valid mode
ax1.plot(IR_plot.runningMeanFast(wave_temp2, smooth), IR_plot.runningMeanFast(reflectance_temp2, smooth), 'b-')

wave_temp=wavelength[2]
reflectance_temp=reflectance[2]
wave_temp3=wave_temp.T
reflectance_temp3=reflectance_temp.T
#for valid mode
ax1.plot(IR_plot.runningMeanFast(wave_temp3, 16), IR_plot.runningMeanFast(reflectance_temp3, 16), 'g-')

ax1.set_xlabel('Wavelength ($\mu$m)')
ax1.set_ylabel('Reflectance')
ax1.set_xlim(x_range)
ax1.set_ylim([0,0.7])
ax1.xaxis.set_minor_locator(AutoMinorLocator(5))
ax1.yaxis.set_minor_locator(AutoMinorLocator(2)) 

#ax1.axvline(1.78, color='r', linestyle='--')
#ax1.text(1.63, 0.17, 'H$_2$O', color='k')
ax1.axvline(1.95, color='r', linestyle='--')
ax1.text(1.81, 0.1, 'H$_2$O', color='k')
#ax1.axvline(2.1, color='r', linestyle='--')
#ax1.text(2.11, 0.18, '-OH', color='k')
#ax1.axvline(2.35, color='r', linestyle='--')
#ax1.text(2.36, 0.15, '-OH', color='k')
#ax1.axvline(2.51, color='r', linestyle='--')
#ax1.text(2.53, 0.22, 'H$_2$O', color='k')
ax1.axvline(2.48, color='r', linestyle='--')
ax1.text(2.5, 0.58, '-OH', color='k')
ax1.axvline(2.8, color='r', linestyle='--')
ax1.text(2.91, 0.51, 'H$_2$O', color='k')
ax1.hlines(.5, 2.81, 3.09, color='r', linestyle='--')
ax1.axvline(3.1, color='r', linestyle='--')

ax1.text(1.63, 0.18, 'epsomite')
ax1.text(1.63, 0.57, 'gypsum', color='b')
ax1.text(1.63, 0.65, 'anhydrite', color='g')

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







sys.exit()	



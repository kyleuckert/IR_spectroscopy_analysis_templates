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
#data and bias (dark fram) path
data_path = 'data/samples/'
#Infagold path
IG_path = 'data/Infragold/'

#########################################################
#define data filelist
#AOTF IR spectrometer benchtop (2012 and later)
#these data have already been corrected for H2O absorption using Glenar's IDL program
sample_filenames_H2O_corr = [data_path+'Geothite_avg_Corrected_Results.txt']

#data from GSFC AOTF, comma seperated .txt files (2012 and later)
#wavelength, reflectance
#samples are already Infragold calibrated
sample_filenames_GSFC_comma = [data_path+'gypsum_vacuum_1_day.txt', data_path+'gypsum_vacuum_5days.txt']

#data from GSFC AOTF, tab separated .txt files (2012 and later)
#wavelength		reflectance
#samples are already Infragold calibrated
sample_filenames_GSFC_no_comma = [data_path+'epsomite_powder.txt']

#GSFC AOTF .fits files (2012 and later, current format)
sample_filenames_fits = [data_path+'Jarosite_avg.fit', data_path+'Gypsum.fit']
IG_filenames_fits = [IG_path+'jarosite_IG.fit', IG_path+'Infragold.fit']

#PASA cashbox .csv (tuning curve for wavelength) (2013)
#these files have unreliable wavelength data, use tuning_curve_2013SEP16.txt
sample_filenames_csv_tuning_curve = [data_path+'FS050_jagged_no_board_2_avereaged.csv']
IG_filenames_csv_tuning_curve = [IG_path+'13_09_10_sample_10_avereaged.csv']

#PASA cashbox .csv (2013)
sample_filenames_csv = [data_path+'Montmorillonite1_01_average.csv', data_path+'anhydrite_rock1_01_raw.csv']
IG_filenames_csv = [IG_path+'Montmorillonite_IG.csv', IG_path+'14_09_23_InfraGold_2_raw.csv']

#PASA cashbox .csv with bad scans (2013)
sample_filenames_csv_bad_scans = [data_path+'cvl020_01_raw.csv', data_path+'cvl021_01_raw.csv', data_path+'cvl022_01_raw.csv']
IG_filenames_csv_bad_scans = [IG_path+'13_12_19_InfraGold_4_raw.csv', IG_path+'13_12_19_InfraGold_4_raw.csv', IG_path+'13_12_19_InfraGold_4_raw.csv']

#PASA cashbox .txt (2015, and later, current format)
#large header
#line 11: wavelength
#line 12: frequency
#line 13-256: reflectance
sample_filenames_PASA_cashbox = [data_path+'FW203_orange_01_raw.txt']
IG_filenames_PASA_cashbox = [IG_path+'InfraGold_5_raw.txt']

#PASA-Lite .txt files (2015 and later, current format)
#large header
#line 11: wavelength
#line 12: frequency
#line 13-256: reflectance
sample_filenames_PASA_lite = [data_path+'Bentonite_01_10_raw.txt', data_path+'Kaolin_01_10_raw.txt']
IG_filenames_PASA_lite = [IG_path+'Bentonite_IG.txt', IG_path+'Kaolin_IG.txt']

#.asc files downloaded from USGS spectral library
#large header
#wavelength		reflectance		err
sample_filenames_USGS = [data_path+'illite_imt1.10996.asc', data_path+'saponite_sapca1.20002.asc']


#bias correction is not completed in this template
#bias frames are only relevant for dark samples (basalt, MnO2)
#collection of these files was not standard practice until Sep 2015
#see PASA analysis template for bias correction

#create ouput directory for figures, if it doesn't exist
if not os.path.exists('output'):
    os.makedirs('output')

#########################################################
#main body
#dictionary with N*2 keys (wavelength and reflectance for each sample)
#where N is the number of data files
data = {}

#read all data
#divide data by Infragold file
#subtract bias file (bias files are also Infragold calibrated)

#AOTF IR spectrometer benchtop (2012)
for index, file in enumerate(sample_filenames_H2O_corr):
	#data stored in dictionary
	#define key based on file name
	key=file.split('samples/',1)[-1]
	key=key.rstrip('.txt')
	#store wavelength and reflectance data in key
	data[key+'_wavelength']=[]
	data[key+'_reflectance']=[]
	#obtain Infragold calibrated data
	data[key+'_wavelength'], data[key+'_reflectance'] = IR_analysis.calibrate_data_H2O_corr(file)
	print 'finished reading file: ', key
	IR_analysis.write_file(key, data[key+'_wavelength'], data[key+'_reflectance'])

#GSFC AOTF, comma seperated txt files (2012 and later)
for index, file in enumerate(sample_filenames_GSFC_comma):
	#data stored in dictionary
	#define key based on file name
	key=file.split('samples/',1)[-1]
	key=key.rstrip('.txt')
	#store wavelength and reflectance data in key
	data[key+'_wavelength']=[]
	data[key+'_reflectance']=[]
	#obtain Infragold calibrated data
	data[key+'_wavelength'], data[key+'_reflectance'] = IR_analysis.calibrate_data(file, 1)
	print 'finished reading file: ', key
	IR_analysis.write_file(key, data[key+'_wavelength'], data[key+'_reflectance'])

#GSFC AOTF, tab separated txt files (2012 and later)
for index, file in enumerate(sample_filenames_GSFC_no_comma):
	#data stored in dictionary
	#define key based on file name
	key=file.split('samples/',1)[-1]
	key=key.rstrip('.txt')
	#store wavelength and reflectance data in key
	data[key+'_wavelength']=[]
	data[key+'_reflectance']=[]
	#obtain Infragold calibrated data
	data[key+'_wavelength'], data[key+'_reflectance'] = IR_analysis.calibrate_data(file, 0)
	print 'finished reading file: ', key
	IR_analysis.write_file(key, data[key+'_wavelength'], data[key+'_reflectance'])

#GSFC AOTF .fits files (2012 and later, current format)
for index, file in enumerate(sample_filenames_fits):
	#data stored in dictionary
	#define key based on file name
	key=file.split('samples/',1)[-1]
	key=key.rstrip('.fit')
	#store wavelength and reflectance data in key
	data[key+'_wavelength']=[]
	data[key+'_reflectance']=[]
	#obtain Infragold calibrated data
	data[key+'_wavelength'], data[key+'_reflectance'] = IR_analysis.calibrate_data_fits(file, IG_filenames_fits[index])
	print 'finished reading file: ', key
	IR_analysis.write_file(key, data[key+'_wavelength'], data[key+'_reflectance'])

#PASA cashbox csv (tuning curve for wavelength) (2013)
for index, file in enumerate(sample_filenames_csv_tuning_curve):
	#data stored in dictionary
	#define key based on file name
	key=file.split('samples/',1)[-1]
	key=key.rstrip('.csv')
	#store wavelength and reflectance data in key
	tuning_curve = 'data/tuning_curve_2013SEP16.txt'
	data[key+'_wavelength']=[]
	data[key+'_reflectance']=[]
	#obtain Infragold calibrated data
	data[key+'_wavelength'], data[key+'_reflectance'] = IR_analysis.calibrate_data_csv_tuning_curve(file, IG_filenames_csv_tuning_curve[index], tuning_curve)
	print 'finished reading file: ', key
	IR_analysis.write_file(key, data[key+'_wavelength'], data[key+'_reflectance'])

#PASA cashbox csv (2013)
for index, file in enumerate(sample_filenames_csv):
	#data stored in dictionary
	#define key based on file name
	key=file.split('samples/',1)[-1]
	key=key.rstrip('.csv')
	#store wavelength and reflectance data in key
	data[key+'_wavelength']=[]
	data[key+'_reflectance']=[]
	#obtain Infragold calibrated data
	data[key+'_wavelength'], data[key+'_reflectance'] = IR_analysis.calibrate_data_csv(file, IG_filenames_csv[index])
	print 'finished reading file: ', key
	IR_analysis.write_file(key, data[key+'_wavelength'], data[key+'_reflectance'])

#PASA cashbox csv with bad scans (2013)
for index, file in enumerate(sample_filenames_csv_bad_scans):
	#data stored in dictionary
	#define key based on file name
	key=file.split('samples/',1)[-1]
	key=key.rstrip('.csv')
	#store wavelength and reflectance data in key
	data[key+'_wavelength']=[]
	data[key+'_reflectance']=[]
	#obtain Infragold calibrated data (integer = bad scans to remove)
	data[key+'_wavelength'], data[key+'_reflectance'] = IR_analysis.calibrate_data_csv_bad_scans(file, IG_filenames_csv_bad_scans[index], 32)
	print 'finished reading file: ', key
	print '(removed bad scans)'
	IR_analysis.write_file(key, data[key+'_wavelength'], data[key+'_reflectance'])

#PASA cashbox txt (2015, and later, current format)
#same analysis as PASA-Lite
for index, file in enumerate(sample_filenames_PASA_cashbox):
	#data stored in dictionary
	#define key based on file name
	key=file.split('samples/',1)[-1]
	key=key.rstrip('.txt')
	#store wavelength and reflectance data in key
	data[key+'_wavelength']=[]
	data[key+'_reflectance']=[]
	#obtain Infragold calibrated data
	data[key+'_wavelength'], data[key+'_reflectance'] = IR_analysis.calibrate_data_PASA_lite(file, IG_filenames_PASA_cashbox[index])
	print 'finished reading file: ', key
	IR_analysis.write_file(key, data[key+'_wavelength'], data[key+'_reflectance'])

#PASA-Lite .txt files (2015 and later, current format)
#same analysis file as PASA cashbox
for index, file in enumerate(sample_filenames_PASA_lite):
	#data stored in dictionary
	#define key based on file name
	key=file.split('samples/',1)[-1]
	key=key.rstrip('.txt')
	#store wavelength and reflectance data in key
	data[key+'_wavelength']=[]
	data[key+'_reflectance']=[]
	#obtain Infragold calibrated data
	data[key+'_wavelength'], data[key+'_reflectance'] = IR_analysis.calibrate_data_PASA_lite(file, IG_filenames_PASA_lite[index])
	print 'finished reading file: ', key
	IR_analysis.write_file(key, data[key+'_wavelength'], data[key+'_reflectance'])

#asc files downloaded from USGS spectral library
for index, file in enumerate(sample_filenames_USGS):
	#data stored in dictionary
	#define key based on file name
	key=file.split('samples/',1)[-1]
	key=key.rstrip('.asc')
	#store wavelength and reflectance data in key
	data[key+'_wavelength']=[]
	data[key+'_reflectance']=[]
	#obtain Infragold calibrated data
	data[key+'_wavelength'], data[key+'_reflectance'] = IR_analysis.calibrate_data_USGS(file)
	print 'finished reading file: ', key
	IR_analysis.write_file(key, data[key+'_wavelength'], data[key+'_reflectance'])

print 'plotting...'

#gypsum vacuum comparison
#example of a single spectrum plot
#(wavelength, reflectance, xrange, title, save file, smoothing integer)
#Goethite
IR_plot.plot_IR_spectrum(np.array(data['Geothite_avg_Corrected_Results_wavelength']), np.array(data['Geothite_avg_Corrected_Results_reflectance']), [1.6,3.6], '', 'output/Goethite.png', 2)

#example of multiple spectra (2) plot
#([wavelength1, wavelength2, ...], [reflectance1, reflectance2, ...], xrange, title, save file, legend, smoothing integer)
IR_plot.plot_IR_spectra([np.array(data['gypsum_vacuum_1_day_wavelength']), np.array(data['gypsum_vacuum_5days_wavelength'])], [np.array(data['gypsum_vacuum_1_day_reflectance']), np.array(data['gypsum_vacuum_5days_reflectance'])], [1.6,3.6], ' ', 'output/gypsum_vacuum_comparison.png', ['1 day in vacuum', '5 days in vacuum'], 2)

#epsomite
IR_plot.plot_IR_spectrum(np.array(data['epsomite_powder_wavelength']), np.array(data['epsomite_powder_reflectance']), [1.6,3.6], '', 'output/epsomite_powder.png', 2)

#jarosite
IR_plot.plot_IR_spectrum(np.array(data['Jarosite_avg_wavelength']), np.array(data['Jarosite_avg_reflectance']), [1.6,3.6], '', 'output/jarosite.png', 2)

#FSC gypsum
IR_plot.plot_IR_spectrum(np.array(data['FS050_jagged_no_board_2_avereaged_wavelength']), np.array(data['FS050_jagged_no_board_2_avereaged_reflectance']), [1.6,3.6], '', 'output/FSC_gypsum.png', 2)

#Montmorillonite
IR_plot.plot_IR_spectrum(np.array(data['Montmorillonite1_01_average_wavelength']), np.array(data['Montmorillonite1_01_average_reflectance']), [1.6,3.6], '', 'output/Montmorillonite.png', 2)

#actinobacteria
IR_plot.plot_IR_spectrum(np.array(data['FW203_orange_01_raw_wavelength']), np.array(data['FW203_orange_01_raw_reflectance']), [1.6,3.6], 'FW201: cashbox (boxcar smooth size: 10)', 'output/FW203_cashbox_smooth.png', 10)

#Bentonite
IR_plot.plot_IR_spectrum(np.array(data['Bentonite_01_10_raw_wavelength']), np.array(data['Bentonite_01_10_raw_reflectance']), [1.6,3.6], '', 'output/bentonite.png', 2)

#Kaolin
IR_plot.plot_IR_spectrum(np.array(data['Kaolin_01_10_raw_wavelength']), np.array(data['Kaolin_01_10_raw_reflectance']), [1.6,3.6], '', 'output/kaolin.png', 2)

#Illite
IR_plot.plot_IR_spectrum(np.array(data['illite_imt1.10996_wavelength']), np.array(data['illite_imt1.10996_reflectance']), [1.6,3.6], '', 'output/Illite.png', 2)

#saponite
IR_plot.plot_IR_spectrum(np.array(data['saponite_sapca1.20002_wavelength']), np.array(data['saponite_sapca1.20002_reflectance']), [1.6,3.6], '', 'output/saponite.png', 2)


#Ca sulfate comparison - auto
IR_plot.plot_IR_spectra([np.array(data['epsomite_powder_wavelength']), np.array(data['Gypsum_wavelength']), np.array(data['anhydrite_rock1_01_raw_wavelength'])], [21*np.array(data['epsomite_powder_reflectance']), np.array(data['Gypsum_reflectance']), 1.8*np.array(data['anhydrite_rock1_01_raw_reflectance'])], [1.6,3.6], ' ', 'output/Ca_sulfate_comparison.png', ['epsomite', 'gypsum', 'anhydrite'], 10)


#Ca sulfate comparison - with annotations
#########################################################
#to plot something maunally and add annotations:
#add wavelength data to this list
wavelength = [np.array(data['epsomite_powder_wavelength']), np.array(data['Gypsum_wavelength']), np.array(data['anhydrite_rock1_01_raw_wavelength'])]

#add reflectance data to this list
reflectance = [21*np.array(data['epsomite_powder_reflectance']), np.array(data['Gypsum_reflectance']), 1.8*np.array(data['anhydrite_rock1_01_raw_reflectance'])]


#to edit the xrange
x_range=[1.6,3.6]
#name of the save file
save_file='output/Ca_sulfate_comparison_annotated.png'
#smoothing integer (set to 1 for no smoothing)
smooth=[8,8,16]
#offset (if you want to offset each plot vertically):
offset=[0.0, 0.0, 0.0]
#define list for trace colors (k=black, -=solid line)
#see matplotlib documentation for plotting color/symbol options
color = ['k-', 'b-', 'g-']

#sets up the plotting environment
fig = plt.figure()
fig.subplots_adjust(top=0.90)
ax1=fig.add_subplot(111)
ax2=ax1.twiny()
#plot multiple spectra

#plot each trace
for i, wave_temp in enumerate(wavelength):
	wave_temp=wavelength[i]
	reflectance_temp=reflectance[i]
	wave_tempT=wave_temp.T
	reflectance_tempT=reflectance_temp.T
	#only first 2000 points are relevant
	#first few points are nearly 0 (>3.7 microns, stretch y axes)
	#reflectance_tempT=reflectance_tempT[10:2000]
	#wave_tempT=wave_tempT[10:2000]

	#for valid mode
	ax1.plot(IR_plot.runningMeanFast(wave_tempT, smooth[i]), IR_plot.runningMeanFast(reflectance_tempT, smooth[i])+offset[i], color[i])


ax1.set_xlabel('Wavelength ($\mu$m)')
ax1.set_ylabel('Reflectance')
ax1.set_xlim(x_range)
ax1.set_ylim([0,0.7])
ax1.xaxis.set_minor_locator(AutoMinorLocator(5))
ax1.yaxis.set_minor_locator(AutoMinorLocator(2)) 

ax1.axvline(1.95, color='r', linestyle='--')
ax1.text(1.81, 0.1, 'H$_2$O', color='k')
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



#CVL bioverm
wavelength = [np.array(data['cvl020_01_raw_wavelength']), np.array(data['cvl021_01_raw_wavelength']), np.array(data['cvl022_01_raw_wavelength'])]

reflectance=[np.array(data['cvl020_01_raw_reflectance']), np.array(data['cvl021_01_raw_reflectance']), np.array(data['cvl022_01_raw_reflectance'])]

#to edit the xrange
x_range=[1.6,3.6]
#name of the save file
save_file='output/bioverm.png'
#smoothing integer (set to 1 for no smoothing)
smooth=[8,8,16]
#offset (if you want to offset each plot vertically):
offset=[0.0, 0.0, 0.0]
#define list for trace colors (k=black, -=solid line)
#see matplotlib documentation for plotting color/symbol options
color = ['k-', 'b-', 'g-']

#sets up the plotting environment
fig = plt.figure()
fig.subplots_adjust(top=0.90)
ax1=fig.add_subplot(111)
ax2=ax1.twiny()
#plot multiple spectra

#plot each trace
for i, wave_temp in enumerate(wavelength):
	wave_temp=wavelength[i]
	reflectance_temp=reflectance[i]
	wave_tempT=wave_temp.T
	reflectance_tempT=reflectance_temp.T
	#only first 2000 points are relevant
	#first few points are nearly 0 (>3.7 microns, stretch y axes)
	#reflectance_tempT=reflectance_tempT[10:2000]
	#wave_tempT=wave_tempT[10:2000]

	#for valid mode
	ax1.plot(IR_plot.runningMeanFast(wave_tempT, smooth[i]), IR_plot.runningMeanFast(reflectance_tempT, smooth[i])+offset[i], color[i])


ax1.set_xlabel('Wavelength ($\mu$m)')
ax1.set_ylabel('Reflectance')
ax1.set_xlim(x_range)
ax1.set_ylim([0,0.27])
ax1.xaxis.set_minor_locator(AutoMinorLocator(5))
ax1.yaxis.set_minor_locator(AutoMinorLocator(2)) 

ax1.axvline(1.78, color='r', linestyle='--')
ax1.text(1.63, 0.17, 'H$_2$O', color='k')
ax1.axvline(1.93, color='r', linestyle='--')
ax1.text(1.95, 0.2, 'H$_2$O', color='k')
ax1.axvline(2.1, color='r', linestyle='--')
ax1.text(2.11, 0.18, '-OH', color='k')
ax1.axvline(2.35, color='r', linestyle='--')
ax1.text(2.36, 0.15, '-OH', color='k')
ax1.axvline(2.51, color='r', linestyle='--')
ax1.text(2.53, 0.22, 'H$_2$O', color='k')
ax1.axvline(2.72, color='r', linestyle='--')
ax1.text(2.80, 0.13, 'H$_2$O', color='k')
ax1.hlines(.12, 2.74, 2.99, color='r', linestyle='--')
ax1.axvline(3.01, color='r', linestyle='--')

ax1.text(1.63, 0.255, 'host rock')
ax1.text(1.63, 0.12, 'black', color='b')
ax1.text(1.63, 0.11, 'bioverm', color='b')
ax1.text(1.63, 0.06, 'brown', color='g')
ax1.text(1.63, 0.05, 'bioverm', color='g')

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



#import relevant libraries
import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
import matplotlib.cm as cm
import pylab
from matplotlib import gridspec
from matplotlib.ticker import AutoMinorLocator
#import matplotlib.font_manager as fm
#import plotly

#########################################################
#plotting function definitions:
	
def runningMeanFast(x, N):
	return np.convolve(x, np.ones((N,))/N, mode='valid')[(N-1):]
    
#plots a single IR spectrum
def plot_IR_spectrum(wavelength, reflectance, x_range, title, save_file, smooth):
	wavelength=wavelength.T
	reflectance=reflectance.T
	#only first 2000 points are useful
	#first few points are nearly 0 (>3.7 microns, stretchs y axis if included)
	reflectance=reflectance[10:2000]
	wavelength=wavelength[10:2000]
	fig = plt.figure()
	#make room for title (default is 0.95)
	fig.subplots_adjust(top=0.85)
	ax1=fig.add_subplot(111)
	#define ax2 with same data
	ax2=ax1.twiny()
	#plot data
	#need to smooth wavelength as well - smoothing function deletes some sample points near boundaries
	ax1.plot(runningMeanFast(wavelength, smooth), runningMeanFast(reflectance, smooth), 'k-')
	#ax1.plot(wavelength[:,0], runningMeanFast(reflectance[:,0],smooth))
	ax1.set_xlabel('Wavelength ($\mu$m)')
	ax1.set_ylabel('Reflectance')
	ax1.set_xlim(x_range)
	#set minor tick marks
	ax1.xaxis.set_minor_locator(AutoMinorLocator(5))
	ax1.yaxis.set_minor_locator(AutoMinorLocator(2)) 

	#remove tick label and tick marks on top axis
	ax2.xaxis.set_major_formatter(plt.NullFormatter())
	ax2.xaxis.set_minor_formatter(plt.NullFormatter())
	for tic in ax2.xaxis.get_major_ticks():
		tic.tick1On = tic.tick2On = False
		tic.label1On = tic.label2On = False

	#duplicate ax1 on ax2
	ax2=ax1.twiny()
	ax2.set_xlabel('wavenumber (cm$^{-1}$)')
	#list with values of tick mark labels
	wavenumber_label=[]
	#list with values of tick mark locations
	wavenumber_location=[]
	#wavenumber labels as a multiple of 1000 cm^-1
	for loc in range(int(1+(1E4/x_range[0] - 1E4/x_range[1])/1000)):
		wavenumber=int((1E4/x_range[0]) - 1000*loc)/1000*1000
		wavenumber_label.append(wavenumber)
		#define location as a fraction between [0,1]
		location= 1 - ((x_range[1] - 1E4/wavenumber)/(x_range[1] - x_range[0]))
		wavenumber_location.append(location)

	#list with location of minor tick marks
	minor_locator=[]
	#number of minor tick marks
	num_minor=len(wavenumber_location)*3
	#only place minor ticks between major ticks
	#I should add functionality for minor ticks outside as well...
	for i in range(len(wavenumber_location)-1):
		#major tick location separation
		diff=wavenumber_location[i+1]-wavenumber_location[i]
		for j in range(4):
			minor_locator.append((j+1) * (diff/4.0) + wavenumber_location[i])
	
	ax2.set_xticks(wavenumber_location)
	ax2.set_xticklabels(wavenumber_label)
	ax2.xaxis.set_minor_locator(plt.FixedLocator(minor_locator))

	plt.title(title, y=1.11)
	#plt.show()
	pylab.savefig(save_file, dpi=200)
	plt.clf()
	plt.close(fig)


#plots multiple spectra on the same plot in different colors with a legend
def plot_IR_spectra(wavelength, reflectance, x_range, title, save_file, legend_name, smooth):
	fig = plt.figure()
	fig.subplots_adjust(top=0.85)
	ax1=fig.add_subplot(111)
	ax2=ax1.twiny()
	#plot multiple spectra
	for index in range(len(wavelength)):
		wave_temp=wavelength[index]
		reflectance_temp=reflectance[index]
		wave_temp=wave_temp.T
		reflectance_temp=reflectance_temp.T
		#only first 2000 points are relevant
	#first few points are nearly 0 (>3.7 microns, stretchs y axis if included)
		reflectance_temp=reflectance_temp[10:2000]
		wave_temp=wave_temp[10:2000]
		#line extracts color needed for legend
		line, = ax1.plot(wave_temp, runningMeanFast(reflectance_temp, smooth))
		#line, = ax1.plot(wave_temp[:,0], runningMeanFast(reflectance_temp[:,0], smooth))
		ax1.text(0.95, 0.93-(index*0.05), legend_name[index], verticalalignment='bottom', horizontalalignment='right', transform=ax1.transAxes,  color=line.get_color())
		#print wave_temp[400], wave_temp[1600]
		#print max(reflectance_temp[400:1600]) - min(reflectance_temp[400:1600])
	ax1.set_xlabel('Wavelength ($\mu$m)')
	ax1.set_ylabel('Reflectance')
	ax1.set_xlim(x_range)
	#ax1.set_ylim([-1.5,1.5])
	ax1.xaxis.set_minor_locator(AutoMinorLocator(5))
	ax1.yaxis.set_minor_locator(AutoMinorLocator(2)) 

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

	plt.title(title, y=1.11)
	#plt.show()
	pylab.savefig(save_file, dpi=200)
	plt.clf()
	plt.close(fig)

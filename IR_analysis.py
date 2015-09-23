#import relevant libraries
import numpy as np
import sys

#########################################################
#function definitions:

def calibrate_data(sample_file, IG_file):
	#read sample file
	wavelength=[]
	reflectance=[]
	wavelength, reflectance = read_file(sample_file)
	#read IG file
	wavelength_IG=[]
	reflectance_IG=[]
	wavelength_IG, reflectance_IG = read_file(IG_file)

	#only last 2000 points are useful
	#reflectance=reflectance[0:3000]
	#reflectance_IG=reflectance_IG[0:3000]
	wavelength=np.array(wavelength)
	for j, rfl in enumerate(reflectance):
		reflectance[j]=float(rfl)/reflectance_IG[j]
	reflectance=np.array(reflectance)
	#dict_wave.append(wavelength)
	#dict_refl.append(reflectance)
	#dict_wave=wavelength
	#dict_refl=reflectance
	return wavelength, reflectance

def read_file(file):
	#open sample file
	sample=open(file,'r')
	#ignore 10 header lines
	for i in range(10):
		header=sample.readline()
	#for each line in the sample file
	wavelength=[]
	reflectance=[]
	for i, line in enumerate(sample):
		columns=line.split()
		#read wavelength
		if i == 0:
			for wvln in columns:
				wavelength.append(float(wvln))
		#frequency
		elif i==1:
			freq=columns
		#average all reflectance values
		#for first reflectance
		elif i == 2:
			for rfl in columns:
				reflectance.append(float(rfl))
		else:
			for j, rfl in enumerate(columns):
				reflectance[j]=reflectance[j]+float(rfl)

	#find average of sample reflectance
	#last 50 points are considered 0 - used for offset
	for j, rfl_sum in enumerate(reflectance):
		reflectance[j]=rfl_sum/float(i-1)
	offset=np.mean(reflectance[2950:3000])
	for j, rfl in enumerate(reflectance):
		reflectance[j]=float(rfl)-offset
	return wavelength, reflectance


def bias_correct(data_refl, bias_refl):
	bias_corr=[]
	for i, refl in enumerate(data_refl):
		bias_corr.append(refl-bias_refl[i])
		#bias_corr = refl-bias_refl[i]
	bias_corr=np.array(bias_corr)
	return bias_corr





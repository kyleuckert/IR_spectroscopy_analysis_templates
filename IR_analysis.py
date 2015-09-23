#import relevant libraries
import numpy as np
import sys

#########################################################
#function definitions:

#calibrates data files by Infragold reference
def calibrate_data(sample_file, IG_file):
	wavelength=[]
	reflectance=[]
	#read sample file
	wavelength, reflectance = read_file(sample_file)
	wavelength_IG=[]
	reflectance_IG=[]
	#read IG file
	wavelength_IG, reflectance_IG = read_file(IG_file)

	wavelength=np.array(wavelength)
	#divide each element by Infragold reflectance value
	for j, rfl in enumerate(reflectance):
		reflectance[j]=float(rfl)/reflectance_IG[j]
	reflectance=np.array(reflectance)
	return wavelength, reflectance

#read file
def read_file(file):
	#open sample file
	sample=open(file,'r')
	#ignore 10 header lines
	for i in range(10):
		header=sample.readline()
	wavelength=[]
	reflectance=[]
	#for each line in the sample file
	for i, line in enumerate(sample):
		#list of all line values
		columns=line.split()
		#read wavelength
		if i == 0:
			for wvln in columns:
				wavelength.append(float(wvln))
		#read frequency
		elif i==1:
			freq=columns
		#average all reflectance values
		#for first reflectance
		elif i == 2:
			for rfl in columns:
				reflectance.append(float(rfl))
		#for all other reflectance values
		else:
			for j, rfl in enumerate(columns):
				reflectance[j]=reflectance[j]+float(rfl)

	#find average of sample reflectance
	for j, rfl_sum in enumerate(reflectance):
		reflectance[j]=rfl_sum/float(i-1)
	#last 50 points are considered 0 - used for offset
	offset=np.mean(reflectance[2950:3000])
	for j, rfl in enumerate(reflectance):
		reflectance[j]=float(rfl)-offset
	return wavelength, reflectance

#corrects data for bias value
def bias_correct(data_refl, bias_refl):
	bias_corr=[]
	for i, refl in enumerate(data_refl):
		bias_corr.append(refl-bias_refl[i])
		#bias_corr = refl-bias_refl[i]
	bias_corr=np.array(bias_corr)
	return bias_corr





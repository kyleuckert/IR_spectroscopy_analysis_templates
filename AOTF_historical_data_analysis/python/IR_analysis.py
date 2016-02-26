#import relevant libraries
import numpy as np
import sys
from astropy.io import fits

#########################################################
#function definitions:

#calibrates data files by Infragold reference
def calibrate_data(sample_file, del_flag):
	wavelength=[]
	reflectance=[]
	#read sample file
	wavelength, reflectance = read_file(sample_file, del_flag)

	wavelength=np.array(wavelength)
	reflectance=np.array(reflectance)
	return wavelength, reflectance

#read file
def read_file(file, del_flag):
	#open sample file
	sample=open(file,'r')
	#ignore 10 header lines
	#for i in range(10):
		#header=sample.readline()
	wavelength=[]
	reflectance=[]
	#for each line in the sample file
	for line in sample:
		#list of all line values
		#del_flag == 0: space
		#del_flag == 1: comma
		#del_flag == 2: tab
		if del_flag == 0:
			columns=line.split()
		elif del_flag == 1:
			columns=line.split(',')
		elif del_flag == 2:
			columns=line.split('\t')
		else:
			print 'error: invalid delimiter specified'
		#read wavelength
		wavelength.append(float(columns[0]))
		#read reflectance
		reflectance.append(float(columns[1]))
	return wavelength, reflectance


#corrects data for bias value
def bias_correct(data_refl, bias_refl):
	bias_corr=[]
	for i, refl in enumerate(data_refl):
		bias_corr.append(refl-bias_refl[i])
		#bias_corr = refl-bias_refl[i]
	bias_corr=np.array(bias_corr)
	return bias_corr




#calibrates data files by Infragold reference
def calibrate_data_fits(sample_file, IG_file):
	wavenumber=[]
	wavelength=[]
	reflectance=[]
	#read sample file
	reflectance = read_file_fits(sample_file)
	reflectance_IG=[]
	#read IG file
	reflectance_IG = read_file_fits(IG_file)

	#not sure where this came from...
	#or read data/Wavelength_SamplePoint_V2.txt
	for x in range(len(reflectance)):
		wavenumber.append(2621.5+(4.32*(x+1)))
		wavelength.append(1E4/wavenumber[x])

	wavelength_IG=wavelength
	wavelength=np.array(wavelength)
	#divide each element by Infragold reflectance value
	for j, rfl in enumerate(reflectance):
		reflectance[j]=float(rfl)/reflectance_IG[j]
	reflectance=np.array(reflectance)
	return wavelength, reflectance

#read fits file
def read_file_fits(file):
	#open sample file
	sample=fits.open(file)
	reflectance=sample[0].data
	return reflectance


def calibrate_data_PASA_lite(sample_file, IG_file):
	wavelength=[]
	reflectance=[]
	#read sample file
	wavelength, reflectance = read_file_PASA_lite(sample_file)
	wavelength_IG=[]
	reflectance_IG=[]
	#read IG file
	wavelength_IG, reflectance_IG = read_file_PASA_lite(IG_file)

	wavelength=np.array(wavelength)
	#divide each element by Infragold reflectance value
	for j, rfl in enumerate(reflectance):
		reflectance[j]=float(rfl)/reflectance_IG[j]
	reflectance=np.array(reflectance)
	#first few points are nearly 0 (>3.7 microns, stretchs y axis if they are included)
	reflectance=reflectance[10:2000]
	wavelength=wavelength[10:2000]
	return wavelength, reflectance

#read file
def read_file_PASA_lite(file):
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

def calibrate_data_csv_tuning_curve(sample_file, IG_file, tuning_curve):
	#read tuning curve file
	wavelength=[]
	wavelength = read_file_tuning_curve(tuning_curve)	

	reflectance=[]
	#read sample file
	reflectance = read_file_csv(sample_file)
	reflectance_IG=[]
	#read IG file
	reflectance_IG = read_file_csv(IG_file)
	wavelength=np.array(wavelength)
	#divide each element by Infragold reflectance value
	for j, rfl in enumerate(reflectance):
		reflectance[j]=float(rfl)/reflectance_IG[j]
	reflectance=np.array(reflectance)
	reflectance=reflectance[10:2000]
	wavelength=wavelength[10:2000]
	return wavelength, reflectance

#read file: tuning_curve
def read_file_tuning_curve(file):
	#open sample file
	sample=open(file,'r')
	wavelength=[]
	#for each line in the sample file
	for line in sample:
		#read wavelength
		wavelength.append(float(line))
	return wavelength

def calibrate_data_csv(sample_file, IG_file):
	#polynomial coefficients
	A=80.697000e12
	B=50.044000e9
	C=3.062300e6
	D=-1.015300e3
	
	frequency=[]
	wavelength=[]
	for i in range(3000):
		frequency.append((D*(i**3))+(C*(i**2))+(B*i)+A)
		wavelength.append(2.99792458e14/frequency[i])
	
	reflectance=[]
	#read sample file
	reflectance = read_file_csv(sample_file)
	reflectance_IG=[]
	#read IG file
	reflectance_IG = read_file_csv(IG_file)
	wavelength=np.array(wavelength)
	#divide each element by Infragold reflectance value
	for j, rfl in enumerate(reflectance):
		reflectance[j]=float(rfl)/reflectance_IG[j]
	reflectance=np.array(reflectance)
	reflectance=reflectance[10:2000]
	wavelength=wavelength[10:2000]
	return wavelength, reflectance

#read file
def read_file_csv(file):
	#open sample file
	sample=open(file,'r')
	#ignore 1 header line
	header=sample.readline()
	reflectance=[]
	#for each line in the sample file
	for i, line in enumerate(sample):
		#data=sample.readline()
		columns=line.split(',')
		#average all reflectance values
		#for first reflectance
		if i == 0:
			for rfl in columns:
				reflectance.append(float(rfl))
		#for all other reflectance values
		else:
			for j, rfl in enumerate(columns):
				reflectance[j]=reflectance[j]+float(rfl)

	#find average of sample reflectance
	for j, rfl_sum in enumerate(reflectance):
		reflectance[j]=rfl_sum/float(i-1)
	return reflectance

def calibrate_data_csv_bad_scans(sample_file, IG_file, bad):
	#polynomial coefficients
	A=80.697000e12
	B=50.044000e9
	C=3.062300e6
	D=-1.015300e3
	
	frequency=[]
	wavelength=[]
	for i in range(3000):
		frequency.append((D*(i**3))+(C*(i**2))+(B*i)+A)
		wavelength.append(2.99792458e14/frequency[i])
	
	reflectance=[]
	#read sample file
	reflectance = read_file_csv_bad_scans(sample_file, bad)
	reflectance_IG=[]
	#read IG file
	reflectance_IG = read_file_csv_bad_scans(IG_file, bad)
	wavelength=np.array(wavelength)
	#divide each element by Infragold reflectance value
	for j, rfl in enumerate(reflectance):
		reflectance[j]=float(rfl)/reflectance_IG[j]
	reflectance=np.array(reflectance)
	reflectance=reflectance[10:2000]
	wavelength=wavelength[10:2000]
	return wavelength, reflectance

#read file, throw out worst scans
def read_file_csv_bad_scans(file, bad):
	#open sample file
	sample=open(file,'r')
	#ignore 1 header line
	header=sample.readline()
	reflectance=[]
	#calculate number of lines in file (+1 for header)
	num_lines = sum(1 for line in open(file))
	#variable to store all refl values
	refl_all = np.zeros((num_lines, 3000))
	#for each line in the sample file
	for i, line in enumerate(sample):
		columns=line.split(',')
		#store all reflectance values
		#refl_all[i,:] = float(columns)
		for j, rfl in enumerate(columns):
			refl_all[i, j] = float(rfl)
	#remove bad scans
	#holds difference between median and each scan
	diff=refl_all-np.median(refl_all,0)
	#sum of differences over all wavelength points
	var=[]
	for i in range(num_lines):
		var.append(sum(abs(j) for j in diff[i,:]))
	#find row that differs the most from the median
	for i in range(bad-1):
		max_value = max(var)
		max_index = var.index(max_value)
		#print max_value, max_index
		#set spectrum to median value for bad index
		refl_all[max_index,:] = np.median(refl_all,0)
		var[max_index]=0.0

	#find average of sample reflectance
	#median along axis 0
	reflectance = np.mean(refl_all, 0)
	#reflectance = refl_all[1,:]
	return reflectance


#calibrates data files by Infragold reference
def calibrate_data_H2O_corr(sample_file):
	wavelength=[]
	reflectance=[]
	#read sample file
	wavelength, reflectance = read_file_H2O_corr(sample_file)

	wavelength=np.array(wavelength)
	reflectance=np.array(reflectance)
	return wavelength, reflectance

#read file
def read_file_H2O_corr(file):
	#open sample file
	sample=open(file,'r')
	#ignore 7 header lines
	for i in range(7):
		header=sample.readline()
	wavelength=[]
	reflectance=[]
	#for each line in the sample file
	for line in sample:
		#list of all line values
		columns=line.split()
		#read wavelength
		wavelength.append(float(columns[1]))
		#read reflectance
		reflectance.append(float(columns[6]))
	return wavelength, reflectance


#calibrates data files by Infragold reference
def calibrate_data_USGS(sample_file):
	wavelength=[]
	reflectance=[]
	#read sample file
	wavelength, reflectance = read_file_USGS(sample_file)

	wavelength=np.array(wavelength)
	reflectance=np.array(reflectance)
	return wavelength, reflectance

#read file
def read_file_USGS(file):
	#open sample file
	sample=open(file,'r')
	#ignore 16 header lines
	for i in range(16):
		header=sample.readline()
	wavelength=[]
	reflectance=[]
	#for each line in the sample file
	for line in sample:
		#list of all line values
		columns=line.split()
		#read wavelength
		wavelength.append(float(columns[0]))
		#read reflectance
		reflectance.append(float(columns[1]))
	return wavelength, reflectance


#write data file
def write_file(key, wavelength, reflectance):
	#open output file
	output=open('output/'+key+'.txt', 'w')
	for i in range(len(wavelength)):
		output.write(str(wavelength[i]))
		output.write(' ')
		output.write(str(reflectance[i]))
		output.write('\n')
	output.close()


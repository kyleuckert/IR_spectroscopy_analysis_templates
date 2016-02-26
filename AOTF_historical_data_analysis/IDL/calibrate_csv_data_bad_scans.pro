function calibrate_csv_data_bad_scans, file, file_IG, bad
	;calibrates reflectance against Infragold file
	wavelength=fltarr(3000)
	reflectance=fltarr(3000)
	;read sample file
	reflectance = read_csv_file_bad_scans(file, 1, bad)
	wavelength_IG=fltarr(3000)
	reflectance_IG=fltarr(3000)
	;read IG file
	reflectance_IG = read_csv_file_bad_scans(file_IG, 1, bad)
	;divide each element by Infragold reflectance value
	for i=0, 2999 do begin
		reflectance[i]=reflectance[i]/reflectance_IG[i]
	endfor
	return, reflectance
end
function calibrate_txt_data, file, file_IG
	;calibrates reflectance against Infragold file
	wavelength=fltarr(3000)
	reflectance=fltarr(3000)
	;read sample file
	reflectance = read_txt_file(file, 1)
	wavelength_IG=fltarr(3000)
	reflectance_IG=fltarr(3000)
	;read IG file
	reflectance_IG = read_txt_file(file_IG, 1)
	;divide each element by Infragold reflectance value
	for i=0, 2999 do begin
		reflectance[i]=reflectance[i]/reflectance_IG[i]
	endfor
	return, reflectance
end
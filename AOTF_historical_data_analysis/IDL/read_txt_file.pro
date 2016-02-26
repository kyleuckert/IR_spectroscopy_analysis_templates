function read_txt_file, file, flag
	;if flag is 0, wavelength is returned
	;if flag is 1, reflectance is returned
	;total number of lines in file
	n_lines = file_lines(file)
	;subtract header
	n_lines=n_lines-10
	;open sample file
	openr, 99, file
	;ignore header lines, extract polynomial coef values
	header=''
	for i=0, 9 do begin
		readf, 99, header
		;if (i eq 2) then begin
			;A = float(strmid(header, 30))
		;endif
		;if (i eq 3) then begin
			;B = float(strmid(header, 30))
		;endif
		;if (i eq 4) then begin
			;C = float(strmid(header, 30))
		;endif
		;if (i eq 5) then begin
			;D = float(strmid(header, 30))
		;endif
	endfor

	;frequency=D*findgen(3000)^3+C*findgen(3000)^2+B*findgen(3000)+A
	;wavelength=(2.99792458d14)/frequency
	;wavenumber=10000.0d0/wavelength
	
	;only 2000 wavelength points.....
	input2=fltarr(2000)
	frequency=fltarr(2000)
	wavelength=fltarr(2000)
	;only first 2000 points are relevant
	reflectance=fltarr(3000)
	input=fltarr(3000)
	;for each line in the sample file
	for i=0, n_lines-1 do begin
		;wavelength
		if (i eq 0) then begin
			;list of all line values
			readf, 99, input2
			wavelength = input2
		endif
		;frequency
		if (i eq 1) then begin
			readf, 99, input2
			frequency = input2
		endif
		;for first reflectance
		if (i eq 2) then begin
			readf, 99, input
			reflectance = input
		endif 
		if (i gt 2) then begin
			readf, 99, input
			for j=0, 2999 do begin
				reflectance[j] = reflectance[j]+input[j]
			endfor
		endif
	endfor
	close, 99
	
	;find average of sample reflectance
	for j=0, 2999 do begin
		reflectance[j] = reflectance[j]/(n_lines-3)
	endfor
	
	;last 50 points are considered 0 - used for offset
	offset=mean(reflectance(2949:2999))
	for j=0, 2999 do begin
		reflectance[j]=reflectance[j]-offset
	endfor

	if (flag eq 0) then begin
		;returns wavelength array
		return, wavelength
	endif
	if (flag eq 1) then begin
		;returns reflectance array
		return, reflectance
	endif
end
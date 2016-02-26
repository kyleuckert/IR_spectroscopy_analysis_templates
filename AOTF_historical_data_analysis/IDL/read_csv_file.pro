function read_csv_file, file, flag
	;if flag is 0, wavelength is returned
	;if flag is 1, reflectance is returned
	;total number of lines in file
	n_lines = file_lines(file)
	;subtract header
	n_lines=n_lines-1
	;open sample file
	openr, 99, file
	;ignore header lines, extract polynomial coef values
	header=''
	readf, 99, header

	;define wavelength polynomial coefficients
	;this is a mess because the format of the header is incredibly inconsistent....
	A = float(strmid(header, (strsplit(header, 'term A,' ,/regex))[1], (strsplit(header, ','))[2] - (strsplit(header, 'term A,' ,/regex))[1]))
	B = float(strmid(header, (strsplit(header, 'term B,' ,/regex))[1], (strsplit(header, ','))[4] - (strsplit(header, 'term B,' ,/regex))[1]))
	C = float(strmid(header, (strsplit(header, 'term C,' ,/regex))[1], (strsplit(header, ','))[6] - (strsplit(header, 'term C,' ,/regex))[1]))
	D = float(strmid(header, (strsplit(header, 'term D,' ,/regex))[1], (strpos(header, ',number') - (strsplit(header, 'term D,' ,/regex))[1])))
	
	frequency=D*findgen(3000)^3+C*findgen(3000)^2+B*findgen(3000)+A
	wavelength=(2.99792458d14)/frequency
	wavenumber=10000.0d0/wavelength

	reflectance=fltarr(3000)
	input=fltarr(3000)
	;for each line in the sample file
	for i=0, n_lines-1 do begin
		;for first reflectance
		if (i eq 0) then begin
			readf, 99, input
			reflectance = input
		endif 
		if (i gt 0) then begin
			readf, 99, input
			for j=0, 2999 do begin
				reflectance[j] = reflectance[j]+input[j]
			endfor
		endif
	endfor
	close, 99
	
	;find average of sample reflectance
	for j=0, 2999 do begin
		reflectance[j] = reflectance[j]/(n_lines)
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
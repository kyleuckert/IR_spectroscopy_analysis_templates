function bias_correct, data_reflectance, bias_reflectance
	;corrects data for bias value
	bias_corr = fltarr(3000)
	for i=0, 2999 do begin
		bias_corr[i] = data_reflectance[i] - bias_reflectance[i]
	endfor
	;returns bias corrected reflectance array
	return, bias_corr
end
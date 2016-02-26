function median_filter, data, remove_val
	;remove bad scans
	;remove_val - the number of scans to remove
	;find the median value in each channel
	data_med=median(data, dimension=1)
	diff=dblarr(256,3000)
	for x=0, 256-1 do begin
		;the first few (139) scans are outside the 1.6-3.6 range
		for y=139, 3000-1 do begin
			diff(x,y)=abs(data(x,y)-data_med(y))
		endfor
	endfor
	;remove X of the worst scans
	;bad scans have values very far from the median vale for a channel
	bad_scans=dblarr(remove_val+1)
	;throw out last scan (why?)
	bad_scans(remove_val)=256
	for k=0, n_elements(bad_scans)-2 do begin
		temp_max=max(diff,index)
	    ;print, max(diff,index), index
	    bad_scans(k)=index mod 256;index/3000
	    diff(index mod 256,*)=0
	endfor
	good_data=dblarr(256-remove_val,3000)
	sorted_bad=bad_scans(sort(bad_scans))
	z=0
	x=0
	for k=0, 256 - 1 do begin
		if (k lt sorted_bad(x)) then begin
			good_data(z,*)=data(z,*)
	        z=z+1
		endif else if (k eq sorted_bad(x)) then begin
    		x = x+1
		endif
	endfor
	;average the remaining scans
	avg_data=dblarr(3000)
	avg_data=mean(good_data,dimension=1)
	return, avg_data
end
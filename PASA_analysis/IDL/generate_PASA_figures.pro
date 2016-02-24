pro generate_PASA_figures

;cd, '/Users/kyleuckert/Dropbox/Astrobiology/AOTF/Analysis/Nancy_PASA_paper/'

;$\ls /Users/kyleuckert/Dropbox/Astrobiology/AOTF/DATA/2014SEP19/Infragold/ | grep '.txt' > /Users/kyleuckert/Dropbox/Astrobiology/AOTF/Analysis/2014SEP19/Infragold/Infragold_filenames.txt

;$\ls /Users/kyleuckert/Dropbox/Astrobiology/AOTF/DATA/2014SEP19/samples/ | grep '.txt' > /Users/kyleuckert/Dropbox/Astrobiology/AOTF/Analysis/2014SEP19/Infragold/sample_filenames.txt

;readcol, '/Users/kyleuckert/Dropbox/Astrobiology/MS/Analysis/GSFC2014_summer/L2MS_epsomite_tryp/filenames_3.txt', sample_filename, format='a'

;directory list
path_FS2013oct='/Users/kyleuckert/Google\ Drive/Astrobiology\ Collaboration/AOTF/Ft.\ Stanton\ PASA\ \(2013OCT31\)/data/'
path_FS2013may='/Users/kyleuckert/Google\ Drive/Astrobiology\ Collaboration/AOTF/Ft.\ Stanton\ (2013MAY02)/13_09_10_data/'
path_CVL='/Users/kyleuckert/Google\ Drive/Astrobiology\ Collaboration/AOTF/Cueva\ de\ Villa\ Luz\ PASA\ \(17-20DEC2013\)/data/13_12_19/'

path_FS2013oct_IG='/Users/kyleuckert/Google\ Drive/Astrobiology\ Collaboration/AOTF/Ft.\ Stanton\ PASA\ \(2013OCT31\)/Infragold/'
path_FS2013mayIG='/Users/kyleuckert/Google\ Drive/Astrobiology\ Collaboration/AOTF/Ft.\ Stanton\ (2013MAY02)/Infragold/'
path_CVLIG='/Users/kyleuckert/Google\ Drive/Astrobiology\ Collaboration/AOTF/Cueva\ de\ Villa\ Luz\ PASA\ \(17-20DEC2013\)/Infragold/'


;assign wavelength to each sample point
A=80.697000d12
B=50.044000d9
C=3.062300d6
D=-1.015300d3

frequency=D*findgen(3000)^3+C*findgen(3000)^2+B*findgen(3000)+A
wavelength=(2.99792458d14)/frequency
wavenumber=10000.0d0/wavelength

readcol,'Wavelength_SamplePoint_V2.txt', junk, wavelength_GSFC,format='d,d'
readcol,'tuning_curve_2013SEP16.txt',wavelength_AOTF1, format='d'


;read AOTF data
header=''

;gypsum star PASA
;read data from FS115 and/or FS117
IG_gypsum_star=dblarr(3000,256)
;2:25
openr, 99, path_FS2013oct_IG+'13_10_31_InfraGold_7_raw.csv'
readf, 99, header
readf, 99, IG_gypsum_star
close, 99

IG_gypsum_star=transpose(IG_gypsum_star)
;remove bad scans
IG_gypsum_star=median_filter(IG_gypsum_star, 32)


gypsum_star115=dblarr(3000,256)
;2:30
openr, 99, path_FS2013oct+'FS115_raw.csv'
readf, 99, header
readf, 99, gypsum_star115
close, 99

gypsum_star115=transpose(gypsum_star115)
;remove bad scans
gypsum_star115=median_filter(gypsum_star115, 32)


gypsum_star117=dblarr(3000,256)
header=''
;2:52
openr, 99, path_FS2013oct+'FS117_raw.csv'
readf, 99, header
readf, 99, gypsum_star117
close, 99

gypsum_star117=transpose(gypsum_star117)
;remove bad scans
gypsum_star117=median_filter(gypsum_star117, 32)


;gypsum: FSC May 2013
FS050IG=dblarr(3000)
openr, 99, path_FS2013mayIG+'13_09_10_sample_10_avereaged.csv'
readf, 99, header
readf, 99, FS050IG
close, 99

FS050=dblarr(3000)
openr, 99, path_FS2013may+'FS050_jagged_no_board_2_avereaged.csv'
readf, 99, header
readf, 99, FS050
close, 99



;!p.font=0
!p.thick=8
!x.thick=8
!y.thick=8
!p.charsize=2.5
!p.charthick=4
!p.thick=2
!x.margin=[8.5,2.5]
!y.margin=[3.5,3.5]

set_plot,'ps'
device,filename='gypsum_star_comparison.eps',/encapsulate,xsize=8,ysize=6,/inches,/COURIER,/tt_font,font_size=8;,/portrait;, /landscape
device,/color,bits_per_pixel=8
loadct, 39

plot, wavelength, gypsum_star115/IG_gypsum_star, color=0, thick=2, xrange=[1.6,3.6],xstyle=1,yrange=[0.0,0.3],ystyle=1, xtitle='wavelength (!4l!Xm)',ytitle='Relectance (arbitrary units)', /nodata, xticklen=0.000001,yminor=4;, ytickv=[0,0.2,0.4,0.6,0.8,1.0]

;wavenumber_plot=[6300, 5400, 4500, 3600, 2700]

axis, xaxis=0, xrange=[1.6,3.6],xstyle=1;, xtickinterval=1000
axis, xaxis=1, xrange=(10000.0d0/!x.crange),xstyle=1, xtitle='wavenumber (cm!e-1!n)', xtickinterval=1000


oplot, wavelength_AOTF1, smooth(FS050/FS050IG,8),color=0, linestyle=0, thick=4
oplot, wavelength, smooth(gypsum_star117/IG_gypsum_star,16), color=0,linestyle=0, thick=4


plots, [1.76,1.76],[0,0.3],color=0,linestyle=1,thick=8
xyouts,  1.65,.08, 'H!D2!NO',color=0,charsize=2.25;1.75
plots, [1.95,1.95],[0,0.3],color=0,linestyle=1,thick=8
xyouts,  1.97,.23, 'H!D2!NO',color=0,charsize=2.25;1.75
plots, [2.23,2.23],[0,0.3],color=0,linestyle=1,thick=8
xyouts,  2.07,.15, '-OH',color=0,charsize=2.25;1.75
plots, [2.285,2.285],[0,0.3],color=0,linestyle=1,thick=8
xyouts,  2.30,.13, '-OH',color=0,charsize=2.25;1.75
plots, [2.5,2.5],[0,0.3],color=0,linestyle=1,thick=8
xyouts,  2.51,.2, 'H!D2!NO',color=0,charsize=2.25;1.75
plots, [2.78,2.78],[0,0.3],color=0,linestyle=1,thick=8
xyouts,  2.84,.2, 'H!D2!NO',color=0,charsize=2.25;1.75
plots, [2.8, 2.99], [0.19, 0.19], color=0, linestyle=0, thick=4
;xyouts,  2.85,.2, 'hydration',color=0,charsize=2.25;1.75
plots, [3.01,3.01],[0,0.3],color=0,linestyle=1,thick=8
;xyouts,  3.03,.18, 'H!D2!NO',color=0,charsize=2.25;1.75
plots, [3.35, 3.5], [0.13, 0.13], color=0, linestyle=0, thick=4
xyouts,  3.37,.14, 'CH',color=0,charsize=2.25;1.75

device,/close
set_plot,'x'

















stop
end


;remove bad scans
;remove_val - the number of scans to remove
function median_filter, data, remove_val
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

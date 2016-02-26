function IR_plot_spectra, wavelength, reflectance, title, save_file, legend_names, smoothing_int, color
;define plotting environment parameters
;!p.font=0
!p.thick=8
!x.thick=8
!y.thick=8
!p.charsize=2.5
!p.charthick=4
!p.thick=2
!x.margin=[8.5,2.5]
;if including a title, change this:
;!y.margin=[3.5,6.5]
!y.margin=[3.5,3.5]

set_plot,'ps'
;define size of figure
device,filename=save_file,/encapsulate,xsize=8,ysize=6,/inches,/COURIER,/tt_font,font_size=8;,/portrait;, /landscape
device,/color,bits_per_pixel=8
;load color table
loadct, 39

;create dummy plot (no data is drawn)
;with title:
;plot, wavelength, reflectance, color=0, thick=2, xrange=[1.6,3.6], xstyle=1, title = title, xtitle='wavelength (!4l!Xm)',ytitle='Relectance (arbitrary units)', /nodata, xticklen=0.000001,yminor=4;, ytickv=[0,0.2,0.4,0.6,0.8,1.0]
;without title:
plot, wavelength, reflectance, color=0, thick=2, xrange=[1.6,3.6], xstyle=1, xtitle='wavelength (!4l!Xm)',ytitle='Relectance (arbitrary units)', /nodata, xticklen=0.000001,yminor=4;, ytickv=[0,0.2,0.4,0.6,0.8,1.0]

;define lower x axis (wavelength)
axis, xaxis=0, xrange=[1.6,3.6],xstyle=1;, xtickinterval=1000
;define upper x axis (wavenumber)
axis, xaxis=1, xticks=4, xtitle='wavenumber (cm!e-1!n)', xtickv=[1.66666,2,2.5,3.33333], xtickname=['6000', '5000', '4000', '3000'], xminor=4

;plot data
for i=0, n_elements(wavelength[*,0])-1 do begin
	oplot, wavelength[i,*], smooth(reflectance[i,*],smoothing_int), color=color[i], linestyle=0, thick=4
endfor
al_legend, legend_names, textcolors=color, /top, /right, box=0, linsize=[0.2,0.2]

device,/close
set_plot,'x'

end
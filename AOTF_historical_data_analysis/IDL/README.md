# PASA analysis template: IDL
<b>Description:</b><br>
<p>
This program will calibrate and plot IR spectra collected by PASA-Lite and PASA cashbox
</p>

<b>Instructions:</b><br>
<p>
<i>Define File Names:</i>
<ul>
<li>Open "IR_main.pro"</li>
<li>Define data and Infragold path variables (lines 7-11)</li></ul></p>
	data_path = '/path/to/data/cashbox_data/YY_MM_DD_tests/'
	IG_path = '/path/to/Infragold/files/cashbox_Infragold/'
<p><ul>
<li>Define data file names and associated Infragold and bias file names (lines 15-22)</li>
</ul></p>
	sample_filenames = [data_path+'file1_01_raw.txt', data_path+'file2_01_raw.txt']
	IG_filenames = [IG_path+'Infragold_1_raw.txt', IG_path+'Infragold_2_raw.txt']
	bias_filenames = [data_path+'bias_01_raw.txt', data_path+'bias_02_raw.txt']

<p>
<i>Plot Data:</i>
<ul>
<b>Plot a Single Spectrum</b>
<li>Edit the following template (and place after line 67) with the following required input parameters:</li>
<ul>
<li>wavelength array</li>
<li>reflectance array</li>
<li>plot title</li>
<li>save file name</li>
<li>smoothing integer (>1)</li>
</ul>
</ul></p>
	wavelength_plot=wavelength[where(key eq 'file1'),*]
	reflectance_plot=corr_reflectance[where(key eq 'file1'),0:1999]
	fig = IR_plot_spectrum(wavelength_plot, reflectance_plot, 'file1 IR spectrum', 'output/file1.eps', 1)

<p>
<ul>
<b>Plot Multiple Spectra</b>
<li>Edit the following template (and place after line 67) with the following required input parameters:</li>
<ul>
<li>list of wavelength arrays</li>
<li>list of reflectance arrays</li>
<li>plot title</li>
<li>save file name</li>
<li>legend elements (empty strings ['', ''] for no legend)</li>
<li>smoothing integer (>1)</li>
<li>line trace color array</li>
</ul>
</ul></p>
	wavelength_plot=[wavelength[where(key eq 'file1'),*], wavelength[where(key eq 'file2'),*]]
	reflectance_plot=[corr_reflectance[where(key eq 'file1'),0:1999], corr_reflectance[where(key eq 'file2'),0:1999]]
	fig = IR_plot_spectra(wavelength_plot, reflectance_plot, 'file1 vs file2 IR spectrum', 'output/file1_file2.eps', ['file1', 'file2'], 1, [0, 254])


<p>
<ul>
<b>Plot Annotated Spectra</b>
<li>Edit the template (lines 110-185) with the following required input parameters:</li>
<ul>
<li>list of wavelength arrays</li>
<li>list of reflectance arrays</li>
<li>plot title</li>
<li>save file name</li>
<li>smoothing array (>1)</li>
<li>offset array (vertical offset)</li>
<li>line trace color array</li>
</ul>
<li>Annotations are written using the following:</li>
</ul></p>
	#dashed vertical red line (spanning y range)
	vline, x_location, color=254, linestyle=1, thick=8
	#dashed horizontal red line
	plots, [x1, x2], [y_position, y_position], color=254, linestyle=1, thick=4
	#label
	xyouts,  x_position, y_position, 'H!D2!NO',color=0,charsize=2.25
	
<b>Installation:</b><br>
<p>
<ul>
<li>This program was tested with IDL Version 8.2.3, Mac OS X</li>
<li>Download this github repository (<a href="https://github.com/kyleuckert/IR_spectroscopy_analysis_templates/archive/master.zip">Download ZIP button</a>) and place "IR_main.pro", and orther ".pro" fucntion files in the same directory that you would like the output folder to be created.</li>
<li>Open "IR_main.pro" in a text editor and edit the necessary lines described above</li>
<li>Run "IR_main.pro" through the IDL the command line within the appropriate directory using the following commands:</li>
</ul></p>
	.compile IR_main.pro
	IR_main

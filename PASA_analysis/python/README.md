# PASA analysis template: Python
<b>Description:</b><br>
<p>
This program will calibrate and plot IR spectra collected by PASA-Lite and PASA cashbox
</p>

<b>Instructions:</b><br>
<p>
<i>Define File Names:</i>
<ul>
<li>Open "IR_main.py"</li>
<li>Define data and Infragold path variables (lines 20-24)</li></ul></p>
	data_path = '/path/to/data/cashbox_data/YY_MM_DD_tests/'
	IG_path = '/path/to/Infragold/files/cashbox_Infragold/'
<p><ul>
<li>Define data file names and associated Infragold and bias file names (lines 28-35)</li>
</ul></p>
	sample_filenames = [data_path+'file1_01_raw.txt', data_path+'file2_01_raw.txt']
	IG_filenames = [IG_path+'Infragold_1_raw.txt', IG_path+'Infragold_2_raw.txt']
	bias_filenames = [data_path+'bias_01_raw.txt', data_path+'bias_02_raw.txt']

<p>
<i>Plot Data:</i>
<ul>
<b>Plot a Single Spectrum</b>
<li>Edit the following template (and place after line 82) with the following required input parameters:</li>
<ul>
<li>wavelength dictionary value (converted to array)</li>
<li>reflectance dictionary value (converted to array)</li>
<li>x axis range</li>
<li>plot title</li>
<li>save file name</li>
<li>smoothing integer (>1)</li>
</ul>
</ul></p>
	IR_plot.plot_IR_spectrum(np.array(data['file1_wavelength']), np.array(data_corr['file1_reflectance']), [1.6,3.6], 'file1 IR spectrum', 'output/file1.png', 10)

<p>
<ul>
<b>Plot Multiple Spectra</b>
<li>Edit the following template (and place after line 82) with the following required input parameters:</li>
<ul>
<li>list of wavelength dictionary values (converted to array)</li>
<li>list of reflectance dictionary values (converted to array)</li>
<li>x axis range</li>
<li>plot title</li>
<li>save file name</li>
<li>legend elements (empty strings ['', ''] for no legend)</li>
<li>smoothing integer (>1)</li>
</ul>
</ul></p>
	IR_plot.plot_IR_spectra([np.array(data['file1_wavelength']), np.array(data['file2_wavelength'])], [np.array(data_corr['file1_reflectance']), np.array(data_corr['file2_reflectance'])], [1.6,3.6], 'file1 vs file2 IR spectrum', 'output/file1_file2.png', ['file1', 'file2'], 10)

<p>
<ul>
<b>Plot Annotated Spectra</b>
<li>Edit the template (lines 110-211) with the following required input parameters:</li>
<ul>
<li>list of wavelength dictionary values (converted to array)</li>
<li>list of reflectance dictionary values (converted to array)</li>
<li>x axis range</li>
<li>plot title</li>
<li>save file name</li>
<li>smoothing list (>1)</li>
<li>trace color list ('k-' for a solid black line)</li>
</ul>
<li>Annotations are written using the following:</li>
</ul></p>
	#dashed vertical red line (spanning y range)
	ax1.axvline(x_location, color='r', linestyle='--')
	#dashed horizontal red line
	ax1.hlines(y1, x1, x2, color='r', linestyle='--')
	#label
	ax1.text(x_location, y_location, 'H$_2$O', color='k')

<b>Installation:</b><br>
<p>
<ul>
<li>Install Python V2.7 using the <a href="http://continuum.io/downloads">Anaconda distribution</a>, which includes several useful scientific packages that will be necessary for the program to run.</li>
<li>Follow the installation instructions, select the default installation configuration.</li>
<li>Open the "Anaconda Command Prompt".</li>
<li>Type the following commands:</li></ul></p>
	conda install matplotlib
	conda install numpy
<p>
<ul>
<li>Download this github repository (<a href="https://github.com/kyleuckert/PASA_analysis_template/archive/master.zip">Download ZIP button</a>) and place "IR_main.py", "IR_analysis.py", and "IR_plot.py" in the a directory that you would like the output files to be generated in.</li>
<li>Open "IR_main.py" in a text editor and edit the necessary lines described above</li>
<li>Run "IR_main.py" on the command line within the appropriate directory using the following command:</li>
</ul></p>
	python IR_main.py

_v. 1.0.1_  

`stata_secutrial`
========

The `stata_seuctrial` package imports data downloaded from secuTrial into Stata, 
	generates variable and values labels and codes date and datetimes. 

Installation
------------

In order to install `stata_secutrial` from github the github-package is required:

	net install github, from("https://haghish.github.io/github/")

You can then install `stata_secutrial` with:

	github install dcr-unibe-ch/stata_secutrial
	

Usage 
------------

Data has first to be downloaded from secuTrial, which generates a zip file named
	*p_export_CSV-xls_Pxxxx_YYYYMMDD-hhmmss.zip* or similar. 
An example export options file is included as *ExportOptions.html*.	Importantly,

-	the *meta data* options must be enabled, and
-	the *store reference value* option must be set to *seperate table*.

The main function `secutrial_prep` needs the specification of 
	the path and exact name of the secuTrial zip-file, or
	the path to the folder containing at least one secuTrial zip-file
	using the **zip()** option.

In the second case, the zip-file with the most recent export is chosen 
	(based on the date and time included in the file name).

The data is then imported and prepared in the folder indicated in **prepped()**.

Example
------------

	# Default settings
	secutrial_prep, zip("path_to_zipfile") prepped("path_to_project\prepared_data")

	# Add alternative ID and centre name, and remove (unnecessary) system variables
	secutrial_prep, zip("path_to_zipfile") prepped("path_to_project\prepared_data") addid addcentre removesys


Authors
------

**Lukas Bütikofer & Alan Haynes**  
DCR Bern  
lukas.buetikofer@unibe.ch  
<https://github.com/dcr-unibe-ch/stata_secutrial>  

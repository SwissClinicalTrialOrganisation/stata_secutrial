_v. 1.0.0_  

`stata_secutrial`
========

The `stata_seuctrial` package imports data dowloaded from secuTrial it into Stata and labels it. 
The main function is called `secutrial_prep'. It handles, variable labels, value labels, dates and datetimes.

An example export options file is included as ExportOptions.html.
The important thing for the program to work is that the *meta data* options 
	are enabled and the *store reference value* option is set to *seperate table*.

Installation
------------

In order to install `stata_secutrial` from github the github-package is required:

	net install github, from("https://haghish.github.io/github/")

You can then install `stata_secutrial` with:

	github install dcr-unibe-ch/stata_secutrial
	

Example
------------

	# Default settings
	stata_secutrial, zip(path_to_project/original_data/p_export_CSV-xls_PXXXX_YYYYMMDD-hhmmss) path("path_to_project\prepared_data")

	# Add alternative ID and centre name, and remove (unnecessary) system variables
	stata_secutrial, zip(path_to_project/original_data/p_export_CSV-xls_PXXXX_YYYYMMDD-hhmmss) path("path_to_project\prepared_data") addid addcentre removesys


Authors
------

**Lukas Bütikofer** & **Alan Haynes**	
DCR Bern  
lukas.buetikofer@unibe.ch  
<https://github.com/dcr-unibe-ch/stata_secutrial>  

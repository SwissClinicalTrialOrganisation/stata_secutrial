{smcl}
{* *! version 1.0.1  05June2026}{...}
{hline}
{cmd:help secutrial_prep}
{hline}

{title:Title}

{phang}
{bf:secutrial_prep} {hline 2} Imports secuTrial data into Stata,
	generates variable and values labels, and codes date and datetimes.


{marker syntax}{...}
{title:Syntax}

{p 4 6 2}
{cmdab:secutrial_prep} {cmd:,} {opth zip(string)} {opth prepped(string)} [{it:options}]

{synoptset 38 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt:{opth zip(string)}} path to the zip file downloaded from secuTrial {p_end}
{synopt:{opth prepped(string)}} path to the folder where the data should be stored {p_end}

{syntab:Optional}
{synopt:{opt addi:d}} adds additional ID (mnpaid) to all forms {p_end}
{synopt:{opt addc:entre}} adds centre name to all forms {p_end}
{synopt:{opt rem:ovesys}} removes most (usually unnecessary) system variables{p_end}
{synopt:{opth keepsys(string)}} keeps specified system variables{p_end}
{synopt:{opt fullf:ormnames}} keep the full form names{p_end}

{marker description}{...}
{title:Description}

{pstd}	
The data has to be dowloaded from secuTrial via the export tool, which produces a zip file.
The path to the zip file and optionally the file name have to be specified using {opt zip()}.
If the file name is not specified, the file with the most recent export date and time is used 
(among the files with default secuTrial naming pattern, i.e. suffix {it:_YYYYMMDD-hhmmss.zip}.

{pstd}
The imported and labelled files are stored under {opt prepped()} in two automatically generated folders:
{it:raw_data} contains the unlabelled raw dta files, {it:labelled_data} the labelled files with shortened file names.
Both inlcude a subfolder {it:meta_data} with the meta data. {p_end}
	
{pstd}	
Options {opt addi:d} and {opt addc:entre} include the additional ID (mnpaid) and the centre name in each form
	(if meta data files {it:casenodes} and {it:centres} are available).

{pstd}
Option {opt rem:ovesys}  removes a set of usually unnecessary system variables from each form
	(visitstartdate, mnplabid, mnpcnptnid, mnplastedit, mnpptnid, mnplang,
	mnpvispdt, mnpvisfdt, mnpfs0, mnpfs1, mnpfs2, mnpfs3,
	mnpfcs0, mnpfcs1, mnpfcs2, mnpfcs3, mnpfsqa,
	mnpfsct, mnpfssdv, mnphide, sigstatus, sigreason,
	mnpvsno, mnpvslbl, mnpaeid, mnpaedate, mnpaeno,
	mnpaefuid, mnpaefudt, mnpsubdocid, fgid, position). 
	Specific ones can be kept using {opt keepsys()}.
	
	
{pstd}
Option {opt fullf:ormnames} keeps the full file names in the {it:labelled_data} folder, inclusing the {it:mnppXXXX}-prefix. 
	

{marker results}{...}
{title:Stored results}

{phang} {cmd:secutrial_prep} stores the exported files in two folders under {opt prepped()}:{p_end}
{phang2}- {it: raw_data} contains raw dta files and the meta data in subfolder {it:meta_data}{p_end}
{phang2}- {it: labelled_data} contains labelled dta files and the meta data in subfolder{it: meta_data}{p_end}

{synoptset 22 tabbed}{...}
{p2col 5 22 19 2: Scalars}{p_end}
{synopt:{cmd:r(export_date)}}date of export{p_end}
{synopt:{cmd:r(export_datetime)}}datetime of export{p_end}

{marker examples}{...}
{title:Examples}

{phang}{cmd: .secutrial_prep, zip("path_to_zipfile") prepped("path_to_project\prepared_data") addid addcentre removesys} {p_end}
	






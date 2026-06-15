{smcl}
{* *! version 1.1.1  15June2026}{...}
{hline}
{cmd:help newest_zip}
{hline}

{title:Title}

{phang}
{bf:newest_zip} {hline 2} Helper function to identify the newest secuTrial export file in a directrory.


{marker syntax}{...}
{title:Syntax}

{p 4 6 2}
{cmdab:newest_zip} {cmd:,} {opth zip(string)}

{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opth zip(string)}} path to the zip file downloaded from secuTrial {p_end}

{marker description}{...}
{title:Description}

{pstd}	
Identifies the zip file with the most recent secuTrial export among the files with default secuTrial naming pattern.
Depends on the suffix {it:_YYYYMMDD-hhmmss.zip}.


{marker results}{...}
{title:Stored results}

{synoptset 22 tabbed}{...}
{p2col 5 22 19 2: Scalars}{p_end}
{synopt:{cmd:r(newest_zip)}}name of the zip file{p_end}
{synopt:{cmd:r(export_datetimes)}}datetime of export (string){p_end}
{synopt:{cmd:r(export_datetime)}}datetime of export (numeric){p_end}
{synopt:{cmd:r(export_date)}}date of export (numeric){p_end}

{marker examples}{...}
{title:Examples}

{phang}{cmd: .newest_zip, zip("path_to_zipfile")}{p_end}
	






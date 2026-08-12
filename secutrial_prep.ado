*! version 1.1.0 08June2026

***************
*wrapper
***********

cap program drop secutrial_prep
program secutrial_prep, rclass

version 16

syntax, zip(string) prepped(string) ///
	[ADDId ADDCentre REMovesys keepsys(string) FULLFormnames]


//local zip "$path\tecno\"
//local zip "$path\tecno\p_export_CSV-xls_P1645_20260422-074128.zip"

*file names and pathes 

if strpos("`zip'",".zip")==0 {
	newest_zip, zip("`zip'")
	local zipf = "`zip'\" + "`r(newest_zip)'"
	local zip = subinstr("`zipf'",".zip","",1)
}
else {
	
	local zipf `zip' 
}	

local extrdir = subinstr("`zip'",".zip","",1)
qui dis regexm("`zipf'", "_[0-9]+-[0-9]+.zip$")
local pdt = regexs(0)
local sn = subinstr("`zipf'","`pdt'","",.)
local pnumb = strreverse(substr(strreverse("`sn'"),1,strpos(strreverse("`sn'"),"_")-1))
local pstr = "`pnumb'" + subinstr("`pdt'",".zip","",1)
	
local edt = subinstr(subinstr("`pdt'","_","",1),".zip","",1)
local edate = date(substr("`edt'",1,strpos("`edt'","-")-1),"YMD")
local edtime = clock("`edt'","YMDhms")

//dis "`extrdir'"
//dis "`zipf'"
//dis "`pstr'"
//dis %tc `edtime'


*unzip 

local cdir `c(pwd)'

cap	mkdir "`extrdir'"
qui cd "`extrdir'"
qui unzipfile "`zipf'", replace
qui cd "`cdir'"

*paths

cap	shell mkdir "`prepped'"
cap	shell mkdir "`prepped'/raw_data/meta_data"
cap	shell mkdir "`prepped'/labelled_data/meta_data"

*import data  

qui secutrial_import, pathorig("`extrdir'") pathraw("`prepped'/raw_data") stext("`pstr'")

*label 

local ai 
if "`addid'"!="" {
	local ai = "addid"
}
local ac
if "`addcentre'"!="" {
	local ac = "addcentre"
}
local rs
if "`removesys'"!="" {
	local rs = "removesys"
}
local fn 
if "`fullformnames'"!="" {
	local fn = "fullformnames"
}

qui secutrial_label, pathraw("`prepped'/raw_data") pathlab("`prepped'/labelled_data") /// 
	`ai' `ac' `rs' `fn' keepsys(`keepsys') 

*export date 
dis
dis "Prepared export from:"
dis %tc `edtime'

return local export_date `edate'
return local export_datetime `edtime'
return local export_datetimes "`edt'"
return local zip_used "`zipf'"
	 
end


****************************************
* secutrial appends each row with a tab creating an empty variable
****************************************

cap program drop secu_varclear
program define secu_varclear
	qui ds
	local vlist `r(varlist)'
	local wc: word count `vlist'
	local vvar: word `wc' of `vlist'
	local vx = regexm("`vvar'", "v[0-9]+")
	if `vx'==1 {
		sum `vvar'
		if `r(N)'==0 {
			drop `vvar'
		}
	}
end

	
********************
* Import data 
**********************

cap program drop secutrial_import
program secutrial_import, nclass

version 16

syntax, pathorig(string) pathraw(string) stext(string)

*define meta_data
local files: dir "`pathorig'" files "*.*"
local w1: word 1 of `files'
local ext = substr("`w1'",strpos("`w1'","."),.)

tempname res
postfile `res' str244 fname using "`pathraw'/meta_data/metaforms", replace
local files : dir "`pathorig'" files "*`ext'"
foreach file of local files {
	if strpos("`file'","mnpp$pno")!=1 & strpos("`file'","emnpp$pno")!=1 & ///
		strpos("`file'","atmnpp$pno")!=1 & strpos("`file'","atemnpp$pno")!=1  {
		local f=subinstr("`file'",strlower("_`stext'`ext'"),"",.)
		post `res' ("`f'")
	}
}
postclose `res'


*load meta data

use "`pathraw'/meta_data/metaforms", clear
levelsof fname, local(fname)
foreach form of local fname {
	import delimited "`pathorig'/`form'_`stext'`ext'", clear
	secu_varclear
	save "`pathraw'/meta_data/`form'", replace
}


* load  form-data

use "`pathraw'/meta_data/forms", clear
levelsof formtablename, local(fname)
foreach form of local fname {
	import delimited "`pathorig'/`form'_`stext'`ext'", clear
	compress
	secu_varclear
	save "`pathraw'/`form'", replace
}

*forms and items
//items: ffid fgid sequence ffcolname itemtype
//forms:  formid formtablename hidden formname formfamily

use "`pathraw'/meta_data/questions", clear
keep fgid formid formtablename formname fglabel
mmerge formid formname using "`pathraw'/meta_data/forms", type(n:1)
drop if missing(fgid)
mmerge fgid using "`pathraw'/meta_data/items", type(1:n)
keep if _merge==3
save "`pathraw'/meta_data/forms_items", replace

*system variable labels 
tempfile lookup
cap postclose lup 
postfile lup str32 var str100 text using "`lookup'"

post lup ("mnpvisid")					("System: Visit identifier") 
post lup ("visitnumber")				("System: Visit sequence")
post lup ("visittype")					("System: Visit type (fixed/flexible/unscheduled/free)")
post lup ("visitstartdate")				("System: Patient entry into project")
post lup ("mnppid")						("System: System Patient ID")
post lup ("mnpaid")						("System: Additional Patient ID")
post lup ("mnplabid")					("System: Additional Patient ID 2")
post lup ("mnp_regimen_gr")				("System: Randomisation")
post lup ("mnpcnptnid")					("System: Centre Patient ID")
post lup ("mnpctrid")					("System: Centre ID")
post lup ("mnpctrname")					("System: Centre name")
post lup ("mnpcname")					("System: Country name")
post lup ("mnpdocid")					("System: eCRF ID")
post lup ("mnplastedit")				("System: Date of last edit")
post lup ("mnpptnid")					("System: Form last saved by")
post lup ("mnplang")					("System: Language")
post lup ("mnpcvpid")					("System: Participant visit ID")
post lup ("mnpvisno")					("System: Individual number of visit for the given casenode")
post lup ("mnpvispdt")					("System: Planned visit date")
post lup ("mnpvisfdt")					("System: Date of first data entry")
post lup ("mnpfs0")						("System: Review level 1")
post lup ("mnpfs1")						("System: Review level 2")
post lup ("mnpfs2")						("System: Record manually frozen")
post lup ("mnpfs3")						("System: Record frozen by system")
post lup ("mnpfcs0")					("System: Completion status")
post lup ("mnpfcs1")					("System: Errors in record")
post lup ("mnpfcs2")					("System: Warnings in record")
post lup ("mnpfcs3")					("System: Data entry complete")
post lup ("mnpfsqa")					("System: Open query")
post lup ("mnpfsct")					("System: Comment on form status")
post lup ("mnpfssdv")					("System: Source data verification status")
post lup ("mnphide")					("System: Hidden form")
post lup ("sigstatus")					("System: Signature status")
post lup ("sigreason")					("System: Reason for modified data")
post lup ("mnpvsno")					("System: Project version number at time eCRF stored")
post lup ("mnpvslbl")					("System: Project version label at time eCRF stored")
post lup ("mnpaeid")					("System: Unique AE ID")
post lup ("mnpaedate")					("System: AE date")
post lup ("mnpaeno")					("System: AE number for the given casenode")
post lup ("mnpaefuid")					("System: The ID of a follow-up to the Adverse Event")
post lup ("mnpaefudt")					("System: Adverse Event follow up date")
post lup ("mnpsubdocid")				("System: Subdocument ID")
post lup ("fgid")						("System: Repetition id")
post lup ("position") 					("System: Position in repetition of parent document")
post lup ("mnpcs0")						("System: Patient record valid")
post lup ("mnpcs1")						("System: Patient record set as anonymized")
post lup ("mnpcs2")						("System: Patient record frozen")
post lup ("mnpcs3")						("System: Patient record automatically frozen")
post lup ("mnpcs4")						("System: Patient deceased")
post lup ("mnpcs5")						("System: Patient frozen")
post lup ("mnpcs6")						("System: Patient to be deleted")
post lup ("mnpcs7")						("System: Patient has closed visit plan")
post lup ("mnpvisstartdate") 			("System: Patient entry into project")
post lup ("mnp_rando_done_gr") 			("System: Rando group")
post lup ("mnp_rando_done_assigndate")  ("System: Rando datetime")
postclose lup

use "`lookup'",clear

//frame copy system_labels_lookup default, replace
save "`pathraw'/meta_data/sysvars", replace

end 


*****************
*Labelling
****************

cap program drop secutrial_label
program secutrial_label, nclass

version 16

syntax,  pathraw(string) pathlab(string) [ADDId ADDCentre REMovesys keepsys(string) FULLFormnames]


*prepare variable labels
*********************

use "`pathraw'/meta_data/forms_items", clear
keep ffcolname fflabel unit formtablename
replace fflabel=fflabel + " " + unit if !missing(unit)
rename (ffcolname fflabel) (var text)
keep var text formtablename
order var text formtablename
duplicates drop

//for system variables
append using "`pathraw'/meta_data/sysvars"
save "`pathraw'/meta_data/varlabels",replace


*prepare value labels
************************

*visitcodes

use "`pathraw'/meta_data/visitplan", clear
keep mnpvislabel mnpvisid
rename mnpvislabel keytext
rename mnpvisid keynr
gen cat = "mnpvisid_l"
save "`pathraw'/meta_data/visitcode", replace

*labinfo

use "`pathraw'/meta_data/cl", clear
rename code keynr
rename value keytext 
gen var = substr(column,  strpos(column, ".")+1, .)
gen cat = var + "_l"
gen formtablename = substr(column, 1, strpos(column, ".")-1)
keep cat keynr keytext formtablename
//for visits
append using "`pathraw'/meta_data/visitcode"
save "`pathraw'/meta_data/vallabels", replace

*varinfo

tempfile sysvar_varvallabels
use "`pathraw'/meta_data/vallabels", clear
keep if missing(formtablename)
gen var=subinstr(cat,"_l","",.)
keep var cat formtablename
order var cat formtablename
duplicates drop
mmerge var using "`pathraw'/meta_data/sysvars", type(1:1)
drop if _merge==2 //remove string variables
drop _merge
save "`sysvar_varvallabels'", replace

use "`pathraw'/meta_data/forms_items", clear
local v1 0
local v2 0
count if inlist(itemtype,"Popup (Beschr. Gruppe)","Horizontal-Radiobutton")
local v1= `r(N)' 
count if  inlist(itemtype,"Popup (Label Group)","Horizontal Radiobutton","Vertical Radiobutton")
local v2= `r(N)' 

if `v1'>0 {
	keep if inlist(itemtype,"Popup (Beschr. Gruppe)","Horizontal-Radiobutton")>0
}
if `v2'>0 {
	keep if inlist(itemtype,"Popup (Label Group)","Horizontal Radiobutton","Vertical Radiobutton")>0
}
if (`v1'==0 & `v2'==0) | (`v1'>0 & `v2'>0) {
	dis as error "Problem with fields"
	exit
}

gen cat =  ffcolname + "_l"
rename ffcolname var 
keep var cat formtablename
order var cat formtablename
duplicates drop
//sysvar 
append using "`sysvar_varvallabels'"
drop text 
replace cat= var + "_l" if missing(cat)

save "`pathraw'/meta_data/varvallabels", replace


*check addition of id and centre
********
local addidcheck = 0
if "`addid'"!="" {
	capture confirm file "`pathraw'/meta_data/casenodes.dta"
	if _rc {
		dis as error "file `pathraw'/meta_data/casenodes not found, alternative id cannot be added"
	}
	else {
		local addidcheck = 1
	}
}

local addcentrecheck = 0
if "`addcentre'"!="" {
	capture confirm file "`pathraw'/meta_data/casenodes.dta"
	if _rc {
		dis as error "file `pathraw'/meta_data/casenodes not found, centre cannot be added"
	}
	else {
		capture confirm file "`pathraw'/meta_data/centres.dta"
		if _rc {
			dis as error "file `pathraw'/meta_data/centres not found, centre cannot be added"
		}
		else {
			local addcentrecheck = 1
		}
	}	
}
			
*label 
**********

*main data		
use "`pathraw'/meta_data/forms", clear
levelsof formtablename, local(fname)
foreach form of local fname {
	
	tempfile varlabels
	tempfile varvallabels
	tempfile vallabels
	
	*variables
	use "`pathraw'/meta_data/varlabels", clear
	keep if  inlist(formtablename,"`form'","") 
	save "`varlabels'", replace	
	
	*values
	use "`pathraw'/meta_data/varvallabels", clear
	keep if  inlist(formtablename,"`form'","")
	save "`varvallabels'", replace

	use "`pathraw'/meta_data/vallabels", clear
	keep if  inlist(formtablename,"`form'","")
	save "`vallabels'", replace

	
	use "`pathraw'/`form'", clear
	
	*add alternative id: 
	if `addidcheck'==1 {
		mmerge mnppid using "`pathraw'/meta_data/casenodes", ukeep(mnpaid) unmatched(master)
		order mnpaid, before(mnppid)
		drop _merge
	}
	
	*add center 
	if `addcentrecheck'==1 {
		mmerge mnppid using "`pathraw'/meta_data/casenodes", ukeep(mnpctrid) unmatched(master)
		mmerge mnpctrid using "`pathraw'/meta_data/centres", ukeep(mnpctrname mnpcname) unmatched(master)
		if (strpos(mnpctrname,"-")>0) {
			replace mnpctrname = substr(mnpctrname,strpos(mnpctrname,"-") + 2,.)
		}
		order mnpctrname, after(mnppid)
		compress mnpctrname
		drop _merge
	}
	
	*remove system vars 
	if "`removesys'"!="" {
		foreach v in "visitstartdate" ///
			"mnplabid" "mnpcnptnid" "mnplastedit" ///
			"mnpptnid" "mnplang" ///
			"mnpvispdt" "mnpvisfdt" ///
			"mnpfs0" "mnpfs1" "mnpfs2" "mnpfs3" ///
			"mnpfcs0" "mnpfcs1" "mnpfcs2" "mnpfcs3" "mnpfsqa" ///
			"mnpfsct" "mnpfssdv" "mnphide" "sigstatus" "sigreason" ///
			"mnpvsno" "mnpvslbl" ///
			"mnpaedate" "mnpaefuid" "mnpaefudt" "mnpsubdocid" ///
			"fgid" "position" {
			
				if (!inlist("`v'","`keepsys'")) {
					cap drop `v'
				}
		}  
	}
	*label
	xvarlabel , varinfo("`varlabels'")
	xlabel , varinfo("`varvallabels'") labinfo("`vallabels'")
	
	*shorten form names 
	if "`fullformnames'"=="" {
		local rform = regexr("`form'", "mnpp[0-9][0-9][0-9][0-9]", "")
		local rform = regexr("`rform'", "^_", "")
	}
	else	{
		local rform = "`form'"
	}
	save "`pathlab'/`rform'", replace
}


*meta_data

use "`pathraw'/meta_data/metaforms", clear
levelsof fname, local(fname)

foreach form of local fname {
	
	tempfile varlabels
	tempfile varvallabels
	tempfile vallabels
	
	*variables
	use "`pathraw'/meta_data/varlabels", clear
	keep if  formtablename==""
	save "`varlabels'", replace	
	
	*values
	use "`pathraw'/meta_data/varvallabels", clear
	keep if  formtablename==""
	save "`varvallabels'", replace

	use "`pathraw'/meta_data/vallabels", clear
	keep if  formtablename==""
	save "`vallabels'", replace
	
	use "`pathraw'/meta_data/`form'", replace
	xvarlabel , varinfo("`varlabels'")
	xlabel , varinfo("`varvallabels'") labinfo("`vallabels'")
	
	save "`pathlab'/meta_data/`form'", replace
}


*recoding
*************	

*dates and times 

//date
use "`pathraw'/meta_data/items", clear
keep if strpos(itemtype,"dd.mm.yyyy")>0 & strpos(itemtype,"hh:mm")==0
levelsof ffcolname, local(tlist)

//datetime
use "`pathraw'/meta_data/items", clear
keep if strpos(itemtype,"dd.mm.yyyy hh:mm")>0
levelsof ffcolname, local(tlist2)

//time
use "`pathraw'/meta_data/items", clear
keep if strpos(itemtype,"dd.mm.yyyy")==0 & strpos(itemtype,"hh:mm")>0
levelsof ffcolname, local(tlist3)

//time since
use "`pathraw'/meta_data/items", clear
keep if strpos(itemtype,"Time Interval")>0
keep if strpos(itemtype,"h-m")>0
levelsof ffcolname, local(tlist4)

use "`pathraw'/meta_data/items", clear
keep if strpos(itemtype,"Date Interval")>0 
keep if strpos(itemtype,"y-m-d-h-m")>0 
levelsof ffcolname, local(tlist5)

use "`pathraw'/meta_data/forms", clear
levelsof formtablename, local(fname)
foreach form of local fname {
	
	if "`fullformnames'"=="" {
		local rform = regexr("`form'", "mnpp[0-9][0-9][0-9][0-9]", "")
		local rform = regexr("`rform'", "^_", "")
	}
	else {
		local rform = "`form'"
	}
	
	use "`pathlab'/`rform'", clear

	foreach var of local tlist {
		cap confirm variable `var', exact
		if !_rc {
			tempvar t`var'
			gen `t`var'' = string(`var', "%15.0f")
			order `t`var'', after(`var')
			replace `var' = date(`t`var'',"YMD")
			format %td `var'
			drop `t`var''
		}
	}
	
	foreach var of local tlist2 {
		cap confirm variable `var', exact
		if !_rc {
			tempvar t`var'
			gen `t`var'' = string(`var', "%15.0f")
			order `t`var'', after(`var')
			replace `var' = clock(`t`var'',"YMDhm")
			format %tc `var'
			drop `t`var''
		}
	}
	
	foreach var of local tlist3 {
		cap confirm variable `var', exact
		if !_rc {
			tempvar t`var'
			gen `t`var'' = string(`var', "%04.0f")
			order `t`var'', after(`var')
			local lb: var label `var'
			drop `var'
			rename `t`var'' `var'
			replace `var' = "" if `var' == "."
			//gen `var' = `t`var''
			label var `var' "`lb'"
			//order `var', after(`t`var'')
			//drop `t`var''
		}
	}
	
	foreach var of local tlist4 {
		cap confirm variable `var', exact
		if !_rc {
			assert strlen(string(`var'))<=4
			gen `var'_min = 60*real(substr(string(`var',"%04.0f"),1,2)) + ///
				real(substr(string(`var',"%04.0f"),3,.)) if strlen(string(`var',"%04.0f"))<=4
			local lb: var label `var'
			label var `var'_min "`lb'"
			order `var'_min, after(`var')
		}
	}
	
	foreach var of local tlist5 {
		cap confirm variable `var', exact
		if !_rc {
			cap assert strlen(string(`var'))<=5
			gen `var'_min = 24*60*real(substr(string(`var',"%05.0f"),1,1)) ///
				+ 60 * real(substr(string(`var',"%05.0f"),2,2))  ///
				+ real(substr(string(`var',"%05.0f"),4,.)) if strlen(string(`var',"%05.0f"))<=5
			local lb: var label `var'
			label var `var'_min "`lb'"
			order `var'_min, after(`var')
		}
	}	
	
	save "`pathlab'/`rform'", replace	
}


*system variable dates for main and meta data

use "`pathraw'/meta_data/sysvars", clear
keep if strpos(strlower(text),"date")>0 |  strpos(strlower(var),"date")>0
levelsof var, local(lev)

use "`pathraw'/meta_data/forms", clear
levelsof formtablename, local(fname1)

use "`pathraw'/meta_data/metaforms", clear
levelsof fname, local(fname2)

local fname "`fname1' `fname2'"

local wc1: word count `fname1'
local i=0
foreach form of local fname {
	
	local i=`i'+1
	local pathi=cond(`i'>`wc1',"meta_data/","")	
	
	if "`fullformnames'"=="" {
		local rform = regexr("`form'", "mnpp[0-9][0-9][0-9][0-9]", "")
		local rform = regexr("`rform'", "^_", "")
	} 
	else {
		local rform = "`form'"
	}
	
	use "`pathlab'/`pathi'`rform'", clear
	
	foreach var of local lev {

		tempvar slen
		cap gen `slen'=strlen(`var')
		if !_rc {
			qui sum `slen' if !missing(`var')
			assert `r(mean)' != 19 | `r(mean)' != 10 
			local lb: var label `var'
			tempvar tvar
			if `r(mean)'==19 {
				gen `tvar'=clock(`var',"YMDhms")
				format `tvar' %tc
			}
			if `r(mean)'==10 {
				tempvar tvar
				gen `tvar'=date(`var',"YMD")
				format `tvar' %td
			}
			order `tvar', after(`var')
			drop `var'
			rename `tvar' `var'
			label var `var' "`lb'"
		}
		cap drop `slen'
	}
	save "`pathlab'/`pathi'`rform'", replace		
}

* Visit information 

use "`pathlab'/meta_data/visitplanforms", clear
mmerge mnpvisid using "`pathlab'/meta_data/visitplan"
mmerge formid using "`pathlab'/meta_data/forms"
drop if _merge==2
order mnpvis* form*
sort mnpvisid
drop _merge
save "`pathlab'/meta_data/visit_info", replace




end 



*! version 1.0.0 08June2026

****************
*find newest zip file in a directory
*******************

cap program drop newest_zip
program newest_zip, rclass

version 16

syntax, zip(string)

local files: dir "`zip'" files "*.zip", respectcase

tempfile dtfile 
qui postfile res str100 file str20 dts dt using "`dtfile'", replace 

foreach file of local files {
	//dis as text "`file'"
	local dt = strreverse(substr(strreverse("`file'"),5,15))
	local edtime = clock("`dt'","YMDhms")
	//dis %tc `edtime'
	post res ("`file'") ("`dt'") (`edtime')
}	
postclose res 

use "`dtfile'", clear
format %tc dt
gsort -dt 
local usefile = file[1]

*get date and time:
qui dis regexm("`usefile'", "_[0-9]+-[0-9]+.zip$")
local pdt = regexs(0)
local sn = subinstr("`zipf'","`pdt'","",.)
local pnumb = strreverse(substr(strreverse("`sn'"),1,strpos(strreverse("`sn'"),"_")-1))
local pstr = "`pnumb'" + subinstr("`pdt'",".zip","",1)
	
local edt = subinstr(subinstr("`pdt'","_","",1),".zip","",1)
local edate = date(substr("`edt'",1,strpos("`edt'","-")-1),"YMD")
local edtime = clock("`edt'","YMDhms")

dis ""
dis as result "zip file used: "
dis as result "`usefile'"

return local export_d `edate'
return local export_dt `edtime'
return local export_dts "`edt'"
return local newest_zip "`usefile'"

end 

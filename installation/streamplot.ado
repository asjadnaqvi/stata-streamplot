*! streamplot v1.52 (25 Aug 2023)
*! Asjad Naqvi (asjadnaqvi@gmail.com)

* v1.52 (25 Aug 2023): Support for aspect() and saving() added
* v1.51 (28 May 2023): Clean up labcond and offset changes to percentages.
* v1.5  (20 Nov 2022): recenter option added. improved variable precision.
* v1.4  (08 Nov 2022): Major code cleanup and some parts reworked. Observation checks. Palette options. label controls.
* v1.3  (20 Jun 2022): Add marker labels and format options 
* v1.2  (14 Jun 2022): passthru optimizations. error checks. reduce the default smoothing. labels fix
* v1.1  (08 Apr 2022)
* v1.0  (06 Aug 2021)

**********************************
* Step-by-step guide on Medium   *
**********************************

// if you want to go for even more customization, you can read this guide:

* COVID-19 visualizations with Stata Part 8: Ridgeline plots (Joy plots) (30 Oct, 2020)
* https://medium.com/the-stata-guide/covid-19-visualizations-with-stata-part-8-joy-plots-ridge-line-plots-dbe022e7264d


cap program drop streamplot


program streamplot, sortpreserve

version 15
 
	syntax varlist(min=2 max=2 numeric) [if] [in], by(varname) [palette(string) alpha(real 100) smooth(real 3) ] ///
		[ LColor(string)  LWidth(string) labcond(real 0) ] 		///					
		[ YLABSize(string) YLABel(varname)  YLABColor(string) offset(real 15) droplow   ] ///
		[ xlabel(passthru) xtitle(passthru) title(passthru) subtitle(passthru) note(passthru) scheme(passthru) name(passthru) xsize(passthru) ysize(passthru)  ] ///
		[ PERCENT FORMAT(string) RECenter(string) ] 
		[ aspect(passthru) saving(passthru) ]
		
		
		
	// check dependencies
	capture findfile colorpalette.ado
	if _rc != 0 {
		display as error "colorpalette package is missing. Install the {stata ssc install colorpalette, replace:colorpalette} and {stata ssc install colrspace, replace:colrspace} packages."
		exit
	}
	
	capture findfile labmask.ado
	if _rc != 0 {
		qui ssc install labutil, replace
	}
	
	marksample touse, strok
	gettoken yvar xvar : varlist 	


	* Definition  of locals - Default format
	if `"`format'"' == "" local format "%12.0fc"
	


qui {
preserve	
	
	keep if `touse'
	
	isid `varlist' `by' // duplicates check
	
	gen ones = 1
	bysort `by': egen counts = sum(ones)
	egen tag = tag(`by')
	summ counts, meanonly
	 
	if r(min) < 10 {
		if "`droplow'" == "" {	
			count if counts < 10 & tag==1
			di as error "Groups with errors:"
			noi list `by' if counts < 10 & tag==1
			di as error "`r(N)' group(s) (`by') have fewer than 10 observations which is insufficient to use {stata help streamplot:streamplot}."
			exit
		}	
		else {
			drop if counts < 10
		}
	}
	
	count
	if r(N) == 0 {
		di as error "No groups fulfill the criteria for {stata help streamplot:streamplot}."
		exit
	}
	
	drop ones tag counts
	
	sort `by' `xvar' 
	cap drop _fillin
	fillin `by' `xvar' 
	cap drop _fillin
	
	
	cap confirm numeric var `by'
		if _rc!=0 {
			tempvar over2
			encode `by', gen(`over2')
			local by `over2' 
		}
		else {
			tempvar tempov over2
			egen   `over2' = group(`by')
			
			if "`: value label `by''" != "" {
				decode `by', gen(`tempov')		
				labmask `over2', val(`tempov')
			}
			local by `over2' 
		}
	
		
	if "`yreverse'" != "" {
					
		clonevar over2 = `by'
		
		summ `by', meanonly
		replace `by' = r(max) - `over' + 1
		
		if "`: value label over2'" != "" {
			tempvar group2
			decode over2, gen(`group2')			
			replace `group2' = string(over2) if `group2'==""
			labmask `by', val(`group2')
		}
		else {
			labmask `by', val(over2)
		}
	}		
	
	
	collapse (sum) `yvar' if `touse', by(`xvar' `by')

	xtset `by' `xvar' 
			
	// this is technically wrong but we do it anyways  
	// fix in later versions
	
	replace `yvar' = 0 if `yvar' < 0	
	
	tempvar `yvar'_ma7	
	tssmooth ma ``yvar'_ma7'  = `yvar' , w(`smooth' 1 0) 

	// add the range variable on the x-axis
	summ `xvar' if ``yvar'_ma7' != ., meanonly
	
	local xrmin = r(min)
	local xrmax = r(max) + ((r(max) - r(min)) * (`offset' / 100)) 
	
	*cap drop stack_`yvar'
	
	gen double stack_`yvar'	= .
	
	sort `xvar' `by'  
	levelsof `xvar', local(lvls)

	foreach y of local lvls {

		summ `by', meanonly
			replace stack_`yvar'  = ``yvar'_ma7' 				 			if  `xvar'==`y' & `by'==r(min)
			replace stack_`yvar'  = ``yvar'_ma7'  +  stack_`yvar'[_n-1] 	if  `xvar'==`y' & `by'!=r(min)
			
		}	


	sort `by' `xvar'  		
	keep `by' `xvar' `yvar' stack_`yvar'
  
	

** preserve the labels

	local mylab: value label `by'


	levelsof `by', local(idlabels)      // store the id levels
		
	foreach x of local idlabels {       
		local idlab_`x' : label `mylab' `x'  // store the corresponding value label in a macro
		
	}



	reshape wide stack_`yvar' `yvar' , i(`xvar') j(`by') 


	foreach x of local idlabels {        // here we know how many variables we have    

		lab var stack_`yvar'`x'  "`idlab_`x''" 
		lab var       `yvar'`x'  "`idlab_`x''"   
	}

 
	 
	gen stack_`yvar'0 = 0  // we need this for area graphs

	ds `yvar'*
	local items : word count `r(varlist)'
	local items = `items' - 1

	if "`recenter'" == "" | "`recenter'"=="middle"  | "`recenter'"=="mid"  | "`recenter'"=="m" {
		gen double meanval_`yvar'  =  stack_`yvar'`items' / 2
	}
	
	if "`recenter'" == "bottom" | "`recenter'"=="bot" | "`recenter'"=="b" {
		gen meanval_`yvar'  =  0
	}	
	
	if "`recenter'" == "top" | "`recenter'"=="t"  {
		local items2 = `items' + 1
		gen double meanval_`yvar'  =   stack_`yvar'`items2'
	}		
	

	foreach x of varlist stack_`yvar'* {
		gen double `x'_norm  = `x' - meanval_`yvar'
	}	
	
	drop meanval*


	// this part is for the mid points 		

	summ `xvar'
	gen last = 1 if `xvar'==r(max)


	ds stack_`yvar'*norm
	local items : word count `r(varlist)'
	local items = `items' - 2



	forval i = 0/`items' {
		local i0 = `i'
		local i1 = `i' + 1

		gen double y`yvar'`i1'  = (stack_`yvar'`i0'_norm + stack_`yvar'`i1'_norm) / 2 if last==1
	}



egen lastsum_`yvar'  = rowtotal(`yvar'*)  if last==1


foreach x of varlist `yvar'* {
	gen double `x'_share = (`x' / lastsum_`yvar') * 100
	}


drop lastsum*

**** automate this part


	ds stack_`yvar'*norm
	local items : word count `r(varlist)'
	local items = `items' - 1

	foreach x of numlist 1/`items' {
		
		
		   * Addition of percent and format (Marc Kaulisch)
		   if `"`percent'"'!="" {
			local ylabvalues `"string(`yvar'`x'_share, `"`format'"') + "%""'
			
			local labvar `yvar'`x'_share
			
		   }
		   else {
			local ylabvalues `"string(`yvar'`x', `"`format'"')"'
			
			local labvar `yvar'`x'
		   }
		   
		   di "`labvar'"

		local t : var lab `yvar'`x'
		gen label`x'_`yvar'  = "`t'" + " (" + `ylabvalues' + ")" if last==1 & `labvar' >= `labcond' 

	}

	
	if "`ylabsize'" == "" local ylabsize "1.4"
	if "`lcolor'"   == "" local lcolor white
	if "`lwidth'"   == "" local lwidth  0.05
	if "`ylabcolor'" != "palette" local ycolor  `ylabcolor'
	if "`palette'" == "" {
		local palette tableau	
	}
	else {
		tokenize "`palette'", p(",")
		local palette  `1'
		local poptions `3'
	}		
	
	

summ stack_`yvar'0_norm, meanonly	

	if "`recenter'" == "" | "`recenter'" == "middle" | "`recenter'" == "mid"  | "`recenter'" == "m" { 

		local ymin = -1 * abs(r(min)) * 1.05
		local ymax =      abs(r(min)) * 1.05
	}
	
	if "`recenter'" == "bottom" | "`recenter'" == "bot"  | "`recenter'" == "b" { 

		local ymin = 0
		local ymax = abs(r(min)) * 1.05
	}	

	if "`recenter'" == "top" | "`recenter'" == "t"  { 

		local ymin = -1 * abs(r(min)) * 1.05
		local ymax =      0
	}		
	
	
ds stack_`yvar'*norm
local items : word count `r(varlist)'
local items = `items' - 2
display `items'

	
forval x = 0/`items' {  

local numcolor = `items' + 1

colorpalette `palette', n(`numcolor') nograph `poptions'

	local x0 =  `x'
	local x1 =  `x' + 1

	local areagraph `areagraph' rarea stack_`yvar'`x0'_norm stack_`yvar'`x1'_norm `xvar', fcolor("`r(p`x1')'") fi(100) lcolor(`lcolor') lwidth(`lwidth') ||

	
	if "`ylabcolor'" == "palette" {
		local ycolor  "`r(p`x1')'"
	}
	
	local labels    `labels'  (scatter y`yvar'`x1' `xvar' if last==1, mlabel(label`x1'_`yvar') mcolor(none) mlabsize(`ylabsize') mlabcolor("`ycolor'")) || 			
		

	}

	
	twoway /// 
		`areagraph' ///
		`labels'	///
			, ///
				legend(off) ///
				yscale(noline) ///
				ytitle("") `xtitle'  ///
				ylabel(`ymin' `ymax', nolabels noticks nogrid) ///
				`xlabel' xscale(noline range(`xrmin' `xrmax'))   ///  
				`title' `subtitle' `note' `scheme' `xsize' `ysize' `name' `aspect' `saving'

restore
}		
		
end



*********************************
******** END OF PROGRAM *********
*********************************

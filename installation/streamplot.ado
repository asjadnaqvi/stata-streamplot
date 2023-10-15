*! streamplot v1.6 (15 Oct 2023)
*! Asjad Naqvi (asjadnaqvi@gmail.com)

* v1.6  (15 Oct 2023): cat() option added. yrev, labcond() fixed. major code cleanup.
* v1.52 (25 Aug 2023): Support for aspect(), saving(), nolabel, nodraw, xscale() and graphregion() added.
* v1.51 (28 May 2023): Clean up labcond and offset changes to percentages.
* v1.5  (20 Nov 2022): recenter option added. improved variable precision.
* v1.4  (08 Nov 2022): Major code cleanup and some parts reworked. Observation checks. Palette options. label controls.
* v1.3  (20 Jun 2022): Add marker labels and format options 
* v1.2  (14 Jun 2022): passthru optimizations. error checks. reduce the default smoothing. labels fix
* v1.1  (08 Apr 2022)
* v1.0  (06 Aug 2021)


cap program drop streamplot

program streamplot, sortpreserve

version 15
 
	syntax varlist(min=2 max=2 numeric) [if] [in], by(varname)  ///
		[ palette(string) alpha(real 100) smooth(real 3) ] ///
		[ LColor(string)  LWidth(string) labcond(real 0) ] 		///					
		[ YLABSize(string) YLABel(varname)  YLABColor(string) offset(real 15)    ] ///
		[ xlabel(passthru) xtitle(passthru) title(passthru) subtitle(passthru) note(passthru) scheme(passthru) name(passthru) xsize(passthru) ysize(passthru)  ] ///
		[ PERCENT FORMAT(string) RECenter(string) ]  ///
		[ aspect(passthru) saving(passthru) NOLABel nodraw xscale(passthru) graphregion(passthru) ]  /// v1.5x
		[ cat(varname) YREVerse  ]   // v1.6
		
		
		
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

	if "`cat'"!= "" {
		qui levelsof `cat'
		if r(r) > 2 {
			di as error "`cat' in cat() is not a binary variable."
			exit 198
		}
	}

	if `"`format'"' == "" local format "%12.0fc"
	


qui {
preserve	
	
	keep if `touse'
	
	
	
	if "`cat'"=="" {
		gen _cat = 1  // run a dummy
		local cat _cat
		local rebasecat 0
	}
	else {
		local rebasecat 1
	}
	
	collapse (sum) `yvar' if `touse', by(`xvar' `by' `cat')
	

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
	
	

	fillin  `by' `xvar' 
	recode `yvar' (.=0)
	sort `xvar' `by' 	
	
	
	
	// pass on cat variable to added observations
	
	bysort `by': replace `cat' = `cat'[_N] if `cat'==.
	cap drop _fillin

	egen _order = group(`cat' `by')  // this is the primary order category
	

	cap confirm numeric var `by'	
		if _rc!=0 {        // if numeric, make sure its numeric is ordered from 1
			tempvar tempov
			encode `by', gen(`over2')
			labmask _order, val(`tempov')
		}
		else {  // if string
			 
						
			if "`: value label `by''" != "" {
				tempvar tempov
				decode `by', gen(`tempov')		
				labmask _order, val(`tempov')
			}
			else {
				labmask _order, val(`by')

			}
		}
	
	local by _order
	
	
	
	if "`yreverse'" != "" {
					
		clonevar over2 = `by'
		
		summ `by', meanonly
		replace `by' = r(max) - `by' + 1
		
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
	
	
	keep  `xvar' `cat' `by' `yvar' 
	order `xvar' `cat' `by' `yvar' 
	
	xtset `by' `xvar'  
	

	replace `yvar' = 0 if `yvar' < 0	 // this is technically wrong but we do it anyways   // fix in later versions
	tssmooth ma _ma  = `yvar' , w(`smooth' 1 0) 

	// add the range variable on the x-axis
	summ `xvar' if _ma != ., meanonly
	
	if "`nolabel'"!="" local offset 0  // reset to 0
	
	local xrmin = r(min)
	local xrmax = r(max) + ((r(max) - r(min)) * (`offset' / 100)) 
	

	sort `xvar' `by' // extremely important for stack order.	
	by `xvar': gen double _stack = sum(_ma) 
	

	** preserve the labels for use later

	local mylab: value label `by'

	levelsof `by', local(idlabels)      // store the id levels
		
	foreach x of local idlabels {       
		local idlab_`x' : label `mylab' `x'  // store the corresponding value label in a macro
		
	}



	if "`yreverse'" == "" {
		summ `cat'
		summ _order if `cat'==r(max)
		local rebase = r(min) - 1   // if cat is defined, store the rebase index
	}
	else {
		summ `cat'
		summ _order if `cat'==r(max)
		local rebase = r(max) 
	}


	ren `yvar' _yvar
	drop `cat'

	

	reshape wide _stack _yvar _ma  , i(`xvar') j(`by')  

	foreach x of local idlabels {        // here we know how many variables we have    

		lab var _stack`x' "`idlab_`x''" 
		lab var _ma`x'	  "`idlab_`x''"   
		lab var _yvar`x'  "`idlab_`x''" 
	}

		
	 
	gen _stack0 = 0  // we need this for area graphs

	order date _stack0
	
	
	if `rebasecat' == 0 {
		ds _ma*
		local items : word count `r(varlist)'
		local items = `items' - 1

		if "`recenter'" == "" | "`recenter'"=="middle"  | "`recenter'"=="mid"  | "`recenter'"=="m" {
			gen double _meanval  =  _stack`items' / 2
		}
		
		if "`recenter'" == "bottom" | "`recenter'"=="bot" | "`recenter'"=="b" {
			gen _meanval  =  0
		}	
		
		if "`recenter'" == "top" | "`recenter'"=="t"  {
			local items2 = `items' + 1
			gen double _meanval  =   _stack`items2'
		}		
	}
	else {
		gen double _meanval = _stack`rebase'
	}
	
	
	
	foreach x of varlist _stack* {
		gen double `x'_norm  = `x' - _meanval
	}	
	
	drop _meanval


	// this part is for the mid points 		

	summ `xvar'
	gen last = 1 if `xvar'==r(max)

	
	ds _stack*_norm
	local items : word count `r(varlist)'
	local items = `items' - 2



	forval i = 0/`items' {
		local i0 = `i'
		local i1 = `i' + 1

		gen double _ylab`i1'  = (_stack`i0'_norm + _stack`i1'_norm) / 2 if last==1
	}



	egen double _lastsum  = rowtotal(_ma*)  if last==1


	foreach x of varlist _ma* {
		gen double `x'_share = (`x' / _lastsum) * 100
		}


	drop _lastsum


**** automate this part


	ds _stack*norm
	local items : word count `r(varlist)'
	local items = `items' - 1

	foreach x of numlist 1/`items' {
		
		   if `"`percent'"' != "" {
			local ylabvalues `"string(_ma`x'_share, `"`format'"') + "%""'
			
			local labvar _ma`x'_share
			
		   }
		   else {
			local ylabvalues `"string(_yvar`x', `"`format'"')"'
			
			local labvar _yvar`x'
		   }
		   
		   

		local t : var lab _ma`x'
		gen _label`x'  = "`t'" + " (" + `ylabvalues' + ")" if last==1 & `labvar' >= `labcond' 

	}

	
	
	
	if "`ylabsize'"  == "" 			local ylabsize "1.4"
	if "`lcolor'"    == "" 			local lcolor white
	if "`lwidth'"    == "" 			local lwidth  0.05
	if "`ylabcolor'" != "palette" 	local ycolor  `ylabcolor'
	if "`palette'" == "" {
		local palette tableau	
	}
	else {
		tokenize "`palette'", p(",")
		local palette  `1'
		local poptions `3'
	}		
	
	

summ _stack0_norm, meanonly	

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
	
	
	if "`cat'" != "" {
		summ _stack0_norm, meanonly	
		local ymin = -1 * abs(r(min)) * 1.05
		
		summ _stack`items'_norm, meanonly
		local ymax =  1 * abs(r(max)) * 1.05	
	}
	
	
	ds _stack*norm
	local items : word count `r(varlist)'
	local items = `items' - 2
	

	
	forval x = 0/`items' {  

	local numcolor = `items' + 1

	colorpalette `palette', n(`numcolor') nograph `poptions'

		local x0 =  `x'
		local x1 =  `x' + 1

		local areagraph `areagraph' rarea _stack`x0'_norm _stack`x1'_norm `xvar', fcolor("`r(p`x1')'") fi(100) lcolor(`lcolor') lwidth(`lwidth') ||

		
		if "`ylabcolor'" == "palette" {
			local ycolor  "`r(p`x1')'"
		}
		
		
		if "`nolabel'"=="" {
			local labels  `labels'  (scatter _ylab`x1' `xvar' if last==1, mlabel(_label`x1') mcolor(none) mlabsize(`ylabsize') mlabcolor("`ycolor'")) || 		
			
		}	

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
				`title' `subtitle' `note' `scheme' `xsize' `ysize' `name' `aspect' `saving' `nodraw' `xscale' `graphregion'

				
	*/
restore
}		
		
end



*********************************
******** END OF PROGRAM *********
*********************************

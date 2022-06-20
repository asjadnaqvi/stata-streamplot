*! streamplot v1.2 (14 Jun 2022)  
*! Asjad Naqvi (asjadnaqvi@gmail.com)

* v1.2 06 Jun 2022: passthru optimizations. error checks. reduce the default smoothing. labels fix
* v1.1 08 Apr 2022
* v1.0 06 Aug 2021

**********************************
* Step-by-step guide on Medium   *
**********************************

// if you want to go for even more customization, you can read this guide:

* COVID-19 visualizations with Stata Part 8: Ridgeline plots (Joy plots) (30 Oct, 2020)
* https://medium.com/the-stata-guide/covid-19-visualizations-with-stata-part-8-joy-plots-ridge-line-plots-dbe022e7264d


cap program drop streamplot


program streamplot, sortpreserve

version 15
 
	syntax varlist(min=2 max=2 numeric) [if] [in], by(varname) [palette(string) alpha(real 80) smooth(real 3)] ///
		[ LColor(string)  LWidth(string) labcond(string) ] 		///					
		[ YLABSize(real 1.4) YLABel(varname)  YLABColor(string) offset(real 0.12)    ] ///
		[ xlabel(passthru) xtitle(passthru) title(passthru) subtitle(passthru) note(passthru) scheme(passthru) name(passthru) xsize(passthru) ysize(passthru)  ] ///
		[  allopt graphopts(string asis) PERCENT FORMAT(string) * ] 
		
		
		
	// check dependencies
	capture findfile colorpalette.ado
	if _rc != 0 {
		display as error "colorpalette package is missing. Install the {stata ssc install colorpalette, replace:colorpalette} and {stata ssc install colrspace, replace:colrspace} packages."
		exit
	}	
	
	marksample touse, strok
	gettoken yvar xvar : varlist 	


* Definition  of locals - Default format
if `"`format'"' == "" {
local format "%12.0f"	
}


qui {
preserve	
		
		levelsof `xvar'
		if `r(r)' < 5 {
			di as err "The variable{it:`xvar'} has less than 5 obvervations per group. Please choose a dataset with a longer time series."
			exit
		}
		


		
	// prepare the dataset	
	collapse (sum) `yvar' if `touse', by(`xvar' `by')

	xtset `by' `xvar' 
			
	// this is technically wrong but we do it anyways  
	// fix in later versions
	
	replace `yvar' = 0 if `yvar' < 0	
	
	tempvar `yvar'_ma7	
	tssmooth ma ``yvar'_ma7'  = `yvar' , w(`smooth' 1 0) 

	// add the range variable on the x-axis
	summ `xvar' if ``yvar'_ma7' != .
		local xrmin = r(min)
		local xrmax = r(max) + ((r(max) - r(min)) * `offset') 
	
	cap drop stack_`yvar'
	
	gen  stack_`yvar'	= .
	
	sort `xvar' `by'  
	qui levelsof `xvar', local(lvls)

	foreach y of local lvls {

		qui summ `by'
			qui replace stack_`yvar'  = ``yvar'_ma7' 				 			if  `xvar'==`y' & `by'==r(min)
			qui replace stack_`yvar'  = ``yvar'_ma7'  +  stack_`yvar'[_n-1] 	if  `xvar'==`y' & `by'!=r(min)
			
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

gen meanval_`yvar'  =  stack_`yvar'`items' / 2



foreach x of varlist stack_`yvar'* {
	gen `x'_norm  = `x' - meanval_`yvar'
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

	gen y`yvar'`i1'  = (stack_`yvar'`i0'_norm + stack_`yvar'`i1'_norm) / 2 if last==1
}



egen lastsum_`yvar'  = rowtotal(`yvar'*)  if last==1


foreach x of varlist `yvar'* {
	gen `x'_share = (`x' / lastsum_`yvar') * 100
	}


drop lastsum*

**** automate this part


	ds stack_`yvar'*norm
	local items : word count `r(varlist)'
	local items = `items' - 1

	foreach x of numlist 1/`items' {
		
			if "`labcond'" != "" {
				local condition "& `yvar'`x' `labcond'"
			}
			else {
				local condition 
			}
		
		   * Addition of percent and format
		   if `"`percent'"'!="" {
			local ylabvalues `"string(`yvar'`x'_share, `"`format'"') + "%""'
		   }
		   else {
			local ylabvalues `"string(`yvar'`x', `"`format'"')"'
		   }

		local t : var lab `yvar'`x'
		gen label`x'_`yvar'  = "`t'" + " (" + `ylabvalues' + ")"	if last==1  `condition' // 

	}



	
	if "`ylabcolor'" == "" {
		local ycolor  black
	}
	else {
		local ycolor `ylabcolor'
	}	
	
	if "`palette'" == "" {
		local mycolor "CET C6"
	}
	else {
		local mycolor `palette'
	}
	
	if "`lcolor'" == "" {
		local linec white
	}
	else {
		local linec `lcolor'
	}
	
	if "`lwidth'" == "" {
		local linew  0.02
	}
	else {
		local linew `lwidth'
	}
	

summ stack_`yvar'0_norm	
local ymin = -1 * abs(r(min)) * 1.05
local ymax =      abs(r(min)) * 1.05


ds stack_`yvar'*norm
local items : word count `r(varlist)'
local items = `items' - 2
display `items'

	
forval x = 0/`items' {  

local numcolor = `items' + 1

colorpalette `mycolor', n(`numcolor') nograph

	local x0 =  `x'
	local x1 =  `x' + 1

	if "`ylabcolor'" == "palette" {
		local ycolor  "`r(p`x1')'"
	}

	local areagraph `areagraph' rarea stack_`yvar'`x0'_norm stack_`yvar'`x1'_norm `xvar', fcolor("`r(p`x1')'") fi(100) lcolor(`linec') lwidth(`linew') ||
	
	local labels    `labels'  (scatter y`yvar'`x1' `xvar' if last==1, mlabel(label`x1'_`yvar') mcolor(none) mlabsize(`ylabsize') mlabcolor(`ycolor')) || 			
		

	}

	
	twoway /// 
		`areagraph' ///
		`labels'	///
			, ///
				legend(off) ///
				yscale(noline) xscale(noline) ///
				ytitle("") `xtitle'  ///
				ylabel(`ymin' `ymax', nolabels noticks nogrid) ///
				`xlabel' xscale(range(`xrmin' `xrmax'))   ///  
				`title' `subtitle' `note' `scheme' `xsize' `ysize'

restore
}		
		
end



*********************************
******** END OF PROGRAM *********
*********************************

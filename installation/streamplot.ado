*! streamplot v1.1 Naqvi 08.Apr.2022
* v1.0 06.Aug.2021

**********************************
* Step-by-step guide on Medium   *
**********************************

// if you want to go for even more customization, you can read this guide:

* COVID-19 visualizations with Stata Part 8: Ridgeline plots (Joy plots) (30 Oct, 2020)
* https://medium.com/the-stata-guide/covid-19-visualizations-with-stata-part-8-joy-plots-ridge-line-plots-dbe022e7264d


cap program drop streamplot


program streamplot, sortpreserve

version 15
 
	syntax varlist(min=2 max=2 numeric) [if] [in], by(varname) [palette(string) alpha(real 80) smooth(real 6)] ///
		[ LColor(string)  LWidth(string) XLABSize(real 2) labcond(string) ] ///
		[ XLINEPattern(string) XLINEColor(string) XLINEWidth(string) ] ///
		[ YLABSize(real 1.4) YLABel(varname)  XLABColor(string) YLABColor(string)  ] ///
		[ xticks(string) title(string) subtitle(string) note(string) scheme(string) ] ///
		[  allopt graphopts(string asis) * ] 
		
		// xtitle(string) ytitle(string) removed for now.
		
		
	// check dependencies
	capture findfile colorpalette.ado
	if _rc != 0 {
		display as error "colorpalette package is missing. Install the {stata ssc install colorpalette, replace:colorpalette} and {stata ssc install colrspace, replace:colrspace} packages."
		exit
	}	
	
	
	marksample touse, strok
	gettoken yvar xvar : varlist 	
	
qui {
preserve	
		collapse (sum) `yvar' if `touse', by(`xvar' `by')

		xtset `by' `xvar' 
			
	
	
	tempvar `yvar'_ma7
	tssmooth ma ``yvar'_ma7'  = `yvar' , w(`smooth' 1 0) 


	// this is technically wrong but we do it anyways
	replace `yvar' = 0 if `yvar' < 0

	
	
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
  
*ren stack_`yvar' cases



** preserve the labels


levelsof `by', local(idlabels)      // store the id levels
	
foreach x of local idlabels {       
   	local idlab_`x' : label `by' `x'  // store the corresponding value label in a macro
	
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

summ date
gen last = 1 if date==r(max)


ds stack_`yvar'*norm
local items : word count `r(varlist)'
local items = `items' - 2
display `items'

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
		

		local t : var lab `yvar'`x'
		gen label`x'_`yvar'  = "`t'" + " (" + string( `yvar'`x', "%12.0f") + ")"	if last==1  `condition'
	}



	if "`xticks'" == "" {
		summ `xvar'
		local xmin = r(min)
		local xmax = r(max) + (r(max) - r(min)) * 0.2
		local gap = round((`xmax' - `xmin') / 10)
		local xti  `xmin'(`gap')`xmax'
	}
	else {
		local xti `xticks'
	}	
	

	if "`xlabcolor'" == "" {
		local xcolor  black
	}
	else {
		local xcolor `xlabcolor'
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
	
	if "`xtitle'" == "" {
		local xtitle = ""
	}
	else {
		local xtitle = `xtitle'
	}	

	/*   // removed for now
	if "`xlinepattern'" != "" {
		local xp solid
	}
	else {
		local xp `xlinepattern'
	}
	*/
	
	if "`xlinecolor'" == "" {
		local xc gs13
	}
	else {
		local xc `xlinecolor'
	}	
	
	
	if "`xlinewidth'" == "" {
		local xw vthin
	}
	else {
		local xw `xlinewidth'
	}		
	

summ stack_`yvar'0_norm	
local ymin = -1 * abs(r(min)) * 1.05
local ymax =      abs(r(min)) * 1.05


ds stack_`yvar'*norm
local items : word count `r(varlist)'
local items = `items' - 2
display `items'

	
forval x = 0/`items' {  // total observations - 1
*display "`x'"

local numcolor = `items' + 1

colorpalette `mycolor', n(`numcolor') nograph

	local x0 =  `x'
	local x1 =  `x' + 1


	local areagraph `areagraph' rarea stack_`yvar'`x0'_norm stack_`yvar'`x1'_norm `xvar', fcolor("`r(p`x1')'") fi(100) lcolor(`linec') lwidth(`linew') ||
	
	local labels    `labels'  (scatter y`yvar'`x1' `xvar' if last==1, mlabel(label`x1'_`yvar') mcolor(none) mlabsize(`ylabsize') mlabcolor(`ylabcolor')) || 			
		

	}

	
	twoway /// 
		`areagraph' ///
		`labels'	///
	, ///
		legend(off) ///
		yscale(noline) xscale(noline) ///
		ytitle("") xtitle("")  ///
		ylabel(`ymin' `ymax', nolabels noticks nogrid) ///
		xlabel(`xti', labsize(`xlabsize') labcolor(`xlabcolor') angle(vertical) glwidth(`xw') glpattern(solid) glcolor(`xc')) ///
		title(`title') subtitle(`subtitle') ///
		note(`note') scheme(`scheme')

restore
}		
		
end



*********************************
******** END OF PROGRAM *********
*********************************

*! streamplot v1.9 (08 Feb 2025)
*! Asjad Naqvi (asjadnaqvi@gmail.com)

* v1.9  (08 Feb 2025): droplow taken out. all categories will now draw. label wrapping improved. more checks added. Added laboffset
* v1.82	(10 Jun 2024): add wrap() for label wraps.
* v1.81	(30 Apr 2024): added area option to create stacked area plots.
* v1.8	(25 Apr 2024): added labscale option. Added percent/share as substitutes. more flexible for generic options.
* v1.7	(01 Apr 2024): trendline, yline, drop if by() is missing
* v1.61 (15 Jan 2024): fixed wrong locals. changed ylab to just lab.
* v1.6  (15 Oct 2023): cat() option added. yrev, labcond() fixed. major code cleanup.
* v1.52 (25 Aug 2023): Support for aspect(), saving(), nolabel, nodraw, xscale() and graphregion() added.
* v1.51 (28 May 2023): Clean up labcond and offset changes to percentages.
* v1.5  (20 Nov 2022): recenter option added. improved variable precision.
* v1.4  (08 Nov 2022): Major code cleanup and some parts reworked. Observation checks. Palette options. label controls.
* v1.3  (20 Jun 2022): Add marker labels and format options 
* v1.2  (14 Jun 2022): passthru optimizations. error checks. reduce the default smoothing. labels fix
* v1.1  (08 Apr 2022): First release
* v1.0  (06 Aug 2021): Beta version



cap program drop streamplot

program streamplot, sortpreserve

version 15
 
	syntax varlist(min=2 max=2 numeric) [if] [in], by(varname)  ///
		[ palette(string) alpha(real 100) smooth(real 3) LColor(string)  LWidth(string) labcond(real 0) ] 	///					
		[ LABSize(string) LABColor(string) offset(real 15) format(string) RECenter(string) 				]	///
		[ NOLABel cat(varname) YREVerse  																]  ///  //  v1.5x v1.6
		[ tline TLColor(string) TLWidth(string) TLPattern(string)  	 									] ///	// v1.7
		[ * labprop labscale(real 0.3333) percent share area wrap(numlist >=0 max=1) LABOFFset(real 0) 		]  // 1.8 options
		
		
	// check dependencies
	cap findfile colorpalette.ado
	if _rc != 0 {
		display as error "The palettes package is missing. Please install the {stata ssc install palettes, replace:palettes} and {stata ssc install colrspace, replace:colrspace} packages."
		exit
	}

	cap findfile labmask.ado
		if _rc != 0 quietly ssc install labutil, replace
	
	cap findfile labsplit.ado
		if _rc != 0 quietly ssc install graphfunctions, replace	
	
	
	
	marksample touse, strok
	gettoken yvar xvar : varlist 	

	if "`cat'"!= "" {
		quietly levelsof `cat'
		if r(r) > 2 {
			di as error "`cat' in cat() is not a binary variable."
			exit 198
		}
	}



quietly {
preserve	
	
	keep if `touse'

	drop if missing(`by')
		
	if "`cat'"=="" {
		gen _cat = 1  // run a dummy
		local cat _cat
		local rebasecat 0
	}
	else {
		local rebasecat 1
	}
	
	collapse (sum) `yvar', by(`xvar' `by' `cat')
	
	fillin `by' `xvar'
	
	replace `yvar' = 0 if `yvar' < 0	 // this is technically wrong but we do it anyways 
	recode `yvar' (.=0)
	
	sort `by' `cat' `xvar'
	bysort `by': replace `cat' = `cat'[1] if `cat'==.
	cap drop _fillin	
	
	
	egen _order = group(`cat' `by')  // this is the primary order category
	

	cap confirm numeric var `by'	
		if !_rc {        // if numeric
			if "`: value label `by''" != "" {   // with val labels
				tempvar tempov
				decode `by', gen(`tempov')		
				cap labmask _order, val(`tempov')
				lab val _order _order
			}
			else {				// without val labels
				tempvar tempov
				encode `by', gen(`tempov')
				cap labmask _order, val(`by')
				lab val _order _order
			}
		}
		else {  // if string
			label list
			cap labmask _order, val(`by')
			lab val _order _order
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
	
	if "`area'" != "" {
		bysort `xvar': egen double _sum = sum(`yvar')
		replace `yvar' = (`yvar' / _sum) * 100
		drop _sum
	}
	
	
	tssmooth ma _ma  = `yvar' , w(`smooth' 1 0) 

	// add the range variable on the x-axis

	if "`nolabel'"!="" local offset 0  // reset to 0
	
	summ `xvar' if _ma != ., meanonly
		local xrmin = r(min)
		local xrmax = r(max) + ((r(max) - r(min)) * (`offset' / 100)) 
	

	sort `xvar' `by' // extremely important for stack order.	
	by `xvar': gen double _stack = sum(_ma) 
	
	if `rebasecat' == 1 {
		egen _temp = group(`cat')
		gen _nsval = _ma * (_temp==2) + -_ma * (_temp==1)
		by `xvar': egen double _linevar = sum(_nsval) 
	}
	else {
		bysort `xvar': egen double _linevar = max(_stack)
	}
	

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

	summ _order, meanonly
	local lastval = r(max)
	
	
	ren `yvar' _yvar
	
	cap drop `cat' _temp _nsval

	reshape wide _stack _yvar _ma  , i(`xvar' _linevar) j(`by')  

	foreach x of local idlabels {        // here we know how many variables we have    

		lab var _stack`x' "`idlab_`x''" 
		lab var _ma`x'	  "`idlab_`x''"   
		lab var _yvar`x'  "`idlab_`x''" 
	}

	
	gen _stack0 = 0  // we need this for area graphs


	order `xvar' _stack0
	
	
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
	
	
	if "`area'" != "" { 	// overwrite
		cap drop _meanval
		gen _meanval = 0
	}
	
	
	foreach x of varlist _stack* {
		gen double `x'_norm  = `x' - _meanval
	}	
	
	if `rebasecat' == 0 	replace _linevar = _linevar - _meanval
	
	// this part is for the mid points 		

	gen double _ylab 		= .
	gen double _yval 		= .
	gen double _yshare 		= .
	gen _yname = ""
	
	ds _stack*_norm
	local items : word count `r(varlist)'
	local items = `items' - 2

	local counter = 1

	forval i = 0/`items' {
		local i0 = `i'
		local i1 = `i' + 1
		local t : var lab _ma`i1'
		
		replace _ylab  = (_stack`i0'_norm[_N] + _stack`i1'_norm[_N]) / 2 in `counter'
		replace _yval = _yvar`i1'[_N] in `counter'
		replace _yname = "`t'" in `counter'
		
		local ++counter
	}

	sum _yval, meanonly
	replace _yshare = (_yval / `r(sum)') * 100

	summ `xvar', meanonly
	gen _xlab = r(max) + `laboffset' if _yval!=.
	
	**** automate this part


	ds _stack*norm
	local items : word count `r(varlist)'
	local items = `items' - 1

	
	if "`format'"  == "" {
		if "`percent'"=="" & "`share'"=="" & "`area'"=="" {			
			local format %15.0fc
		}
		else {
			local format %6.1f
		}
	}		
	
   
	if "`percent'" != "" | "`share'"!="" {
		gen _label  = _yname + " (" + string(_yshare, "`format'")  + "%)" if _yval>0 & !missing(_yval)
	}
	else {
		gen _label  = _yname + " (" + string(_yval, "`format'")  + ")" if _yval>0  & !missing(_yval)    //if last==1 & `labvar' >= `labcond' 
	}
	
	
	if "`wrap'" != "" {
		ren _label _label2
		labsplit _label2, wrap(`wrap') gen(_label)
	}		
	

	if "`labsize'"  == "" 			local labsize 1.6
	if "`lcolor'"    == "" 			local lcolor white
	if "`lwidth'"    == "" 			local lwidth  0.05
	if "`labcolor'" != "palette" 	local ycolor  `labcolor'
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
	

	if "`tline'" != "" {
		if "`tlcolor'"   == "" 	local tlcolor black
		if "`tlwidth'"   == "" 	local tlwidth 0.3
		if "`tlpattern'" == "" 	local tlpattern solid
		
		local trendline (line _linevar `xvar', lc(`tlcolor') lw(`tlwidth') lp(`tlpattern'))
	}
	


	if "`nolabel'"=="" & "`labprop'" == "" & "`labcolor'" !="palette" {
		local labels  `labels'  (scatter _ylab _xlab if _yval >= `labcond' , mlabel(_label) mcolor(none) mlabsize(`labsize') mlabcolor("`labcolor'")) 
	}
	
	
	summ _yval, meanonly
	local height = r(max)
	
	
	ds _stack*norm
	local items : word count `r(varlist)'
	local items = `items' - 2

	local counter = 1

	forval x = 0/`items' {  

		local numcolor = `items' + 1

		colorpalette `palette', n(`numcolor') nograph `poptions'

		local x0 =  `x'
		local x1 =  `x' + 1

		local areagraph `areagraph' rarea _stack`x0'_norm _stack`x1'_norm `xvar', fcolor("`r(p`x1')'") fi(100) lcolor(`lcolor') lwidth(`lwidth') ||
	
		
		if "`labcolor'" == "palette" {
			local ycolor  "`r(p`x1')'"
		}

		
		if "`nolabel'"=="" {
			if "`labprop'" != "" {
				summ _yval in `counter' , meanonly
				local labwgt = `labsize' * (r(max) / `height')^`labscale' 

				local labels `labels' (scatter _ylab _xlab in `counter'  if _yval >= `labcond'	, mlabel(_label) mcolor(none) mlabsize(`labwgt') 	mlabcolor("`ycolor'")) 
				local ++counter
			}
			
			
			if  "`labprop'"=="" & "`labcolor'"=="palette" {

				local labels  `labels'  (scatter _ylab _xlab in `counter'  if _yval >= `labcond', mlabel(_label) mcolor(none) mlabsize(`labsize')	mlabcolor("`ycolor'")) 
				local ++counter
			}	
		}		
	}

	

	*** final graph
	
	twoway /// 
		`areagraph' ///
		`labels'	///									
		`trendline'	///
			, ///
				legend(off) ///
				yscale(noline) ///
				ylabel(`ymin' `ymax', nolabels noticks nogrid) ///
				xscale(noline range(`xrmin' `xrmax')) ///
				`options'  
	
	*/

restore
}		
		
end



*********************************
******** END OF PROGRAM *********
*********************************







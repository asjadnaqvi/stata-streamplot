

![StataMin](https://img.shields.io/badge/stata-2015-blue) ![issues](https://img.shields.io/github/issues/asjadnaqvi/stata-streamplot) ![license](https://img.shields.io/github/license/asjadnaqvi/stata-streamplot) ![Stars](https://img.shields.io/github/stars/asjadnaqvi/stata-streamplot) ![version](https://img.shields.io/github/v/release/asjadnaqvi/stata-streamplot) ![release](https://img.shields.io/github/release-date/asjadnaqvi/stata-streamplot)


[Installation](#Installation) | [Syntax](#Syntax) | [Citation guidelines](#Citation-guidelines) |  [Examples](#Examples) | [Feedback](#Feedback) | [Change log](#Change-log)

---


![streamplot](https://github.com/asjadnaqvi/stata-streamplot/assets/38498046/4b7bbaab-8667-4f47-a119-ec93dcd607a3)


# streamplot v1.9
(08 Feb 2024)

This package provides the ability to generate stream plots in Stata. It is based on the [Streamplot Guide](https://medium.com/the-stata-guide/covid-19-visualizations-with-stata-part-10-stream-graphs-9d55db12318a) (December 2020).


## Installation

The package can be installed via SSC or GitHub. The GitHub version, *might* be more recent due to bug fixes, feature updates etc, and *may* contain syntax improvements and changes in *default* values. See version numbers below. Eventually the GitHub version is published on SSC.

SSC (**v1.82**):
```
ssc install streamplot, replace
```

GitHub (**v1.9**):

```
net install streamplot, from("https://raw.githubusercontent.com/asjadnaqvi/stata-streamplot/main/installation/") replace
```


The following dependencies are required:

```stata
ssc install palettes, replace
ssc install colrspace, replace
ssc install graphfunctions, replace
```

If you want to make a clean figure, then it is advisable to load a clean scheme. These are several available and I personally use the following:

```
ssc install schemepack, replace
set scheme white_tableau  
```

I also prefer narrow fonts in figures with long labels. You can change this as follows:

```stata
graph set window fontface "Arial Narrow"
```


## Syntax

The syntax for the latest version is as follows:

```stata
streamplot y x [if] [in], by(varname) 
            [ palette(str) smooth(num) labcond(str) offset(num) alpha(num) yreverse cat(varname) 
               recenter(top|mid|bot) lcolor(str) lwidth(str) labsize(num) labcolor(color|palette)
               percent format(str) area nolabel wrap(num) tline tlcolor(str) tlwidth(str) 
               tlpattern(str) yline(str) labprop labscale(num) wrap(num) *
            ]
```

See the help file `help streamplot` for details.

The most basic use is as follows:

```stata
streamplot y x, by(varname)
```

where `y` is the variable we want to plot, and `x` is usually the time dimension. The `by` variable splits the data into different groupings that also determines the colors. The color schemes can be modified using the `palettes(name)` option. Here any scheme from the `colorpalettes` package can be used.


## Citation guidelines
Software packages take countless hours of programming, testing, and bug fixing. If you use this package, then a citation would be highly appreciated. 

The [SSC citation](https://ideas.repec.org/c/boc/bocode/s459060.html) is recommended. Please note that the GitHub version might be newer than the SSC version.



## Examples

Set up the data:

```stata
clear
set scheme white_tableau
graph set window fontface "Arial Narrow"

use "https://github.com/asjadnaqvi/stata-streamplot/blob/main/data/streamdata.dta?raw=true", clear

```

We can generate basic graphs as follows:

```stata
streamplot new_cases date, by(region) 
```

<img src="/figures/streamplot1.png" width="100%">

```stata
streamplot new_cases date if date > 22400, by(region) smooth(6)
```

<img src="/figures/streamplot2.png" width="100%">

Recenter the graphs to top or bottom:

```stata
streamplot new_cases date if date > 22400, by(region) smooth(6) recenter(bot)
```

<img src="/figures/streamplot2_1.png" width="100%">

```stata
streamplot new_cases date if date > 22400, by(region) smooth(6) recenter(top)
```

<img src="/figures/streamplot2_2.png" width="100%">


```stata
streamplot new_cases date if date > 22400, by(region) smooth(6) ///
	labcond(20000) ylabsize(1.8) lc(black) lw(0.04)
```

<img src="/figures/streamplot3.png" width="100%">


```stata
streamplot new_cases date if date > 22400, by(region) smooth(6) ///
	labcond(20000) ylabsize(1.8) lc(black) lw(0.04) format(%12.0fc) offset(20)
```

<img src="/figures/streamplot3_1.png" width="100%">


```stata
streamplot new_cases date if date > 22400, by(region) smooth(6) palette(CET D11) ///
	labcond(2) ylabsize(1.8) lc(black) lw(0.04)  percent format(%3.2f) offset(20) ylabc(red)
```

<img src="/figures/streamplot3_2.png" width="100%">

```stata
streamplot new_cases date if date > 22400, by(region) smooth(6) palette(CET C6, reverse) ///
	labcond(1) ylabsize(1.8) lc(black) lw(0.04)  percent format(%3.2f) offset(20) ylabc(palette)
```

<img src="/figures/streamplot3_3.png" width="100%">


Test label wrapping and condition the labels:

```stata
streamplot new_cases date if date > 22400, by(region) smooth(6) palette(CET C6, reverse) wrap(25) labprop ///
	labcond(4e4) labsize(1.8) lc(black) lw(0.04)  offset(20) labc(palette)
```

<img src="/figures/streamplot3_4.png" width="100%">

```stata
qui summ date if date > 22400

local xmin = `r(min)'
local xmax = `r(max)'

streamplot new_cases date if date > 22400, by(region) smooth(6) palette(CET D02)  ///
	title("My Stata stream plot") /// 
	subtitle("Subtitle here") note("Note here") ///
	labcond(20000) ylabsize(1.5) lc(white) lw(0.08) ///
	xlabel(`xmin'(20)`xmax', angle(90)) xtitle("")
```

<img src="/figures/streamplot4.png" width="100%">




or a custom graph scheme:

```stata
streamplot new_cases date if date > 22600, by(region) smooth(6)  palette(CET CBD1)  ///
	title("My Stata stream plot", size(6)) subtitle("with colorblind-friendly colors", size(4))  ///
	labcond(20000) ylabs(2) lc(black) lw(0.03) offset(25) xtitle("") ///
	scheme(neon) 
```

where the dark background `neon` scheme is loaded from the [schemepack](https://github.com/asjadnaqvi/stata-schemepack) suite.


<img src="/figures/streamplot5.png" width="100%">


## v1.6 updates

Test the `yreverse` option:

```
streamplot new_cases date if date > 22400, by(region) smooth(6) ///
	labcond(20000) ylabsize(1.8) lc(black) lw(0.04) format(%12.0fc) offset(20) yrev
```

<img src="/figures/streamplot6.png" width="100%">


Test the region split option. First let's define a variable:

```
gen ns = .
replace ns = 2 if inlist(region, 1, 2, 5, 6, 7, 8)
replace ns = 1 if inlist(region, 3, 4, 9, 10, 11, 12, 13)

lab de ns 2 "North" 1 "South"
lab val ns ns

tab region ns
```

And plot it:

```
streamplot new_cases date if date > 22400, by(region) smooth(6) cat(ns) palette(CET D02) labcond(20000)
```

<img src="/figures/streamplot7.png" width="100%">


We can use the new variable itself in the `by()` option:


```
streamplot new_cases date if date > 22400, cat(ns) by(ns) smooth(6) 
```

<img src="/figures/streamplot8.png" width="100%">

## v1.7 updates

Get the data:

```
use "https://github.com/asjadnaqvi/stata-streamplot/blob/main/data/wbgdpdata.dta?raw=true", clear

drop if year < 1990
gen splitvar = category!="M"
```


```
streamplot value_real year if countrycode=="TSA", by(category) smooth(2) xsize(2) ysize(1)
```

<img src="/figures/streamplot_tline1.png" width="100%">

```
streamplot value_real year if countrycode=="TSA", by(category) cat(splitvar) smooth(2)  xsize(2) ysize(1) 
```

<img src="/figures/streamplot_tline2.png" width="100%">

```
streamplot value_real year if countrycode=="TSA", by(category) cat(splitvar) smooth(2) palette(tab Green-Orange-Teal) ///
	yline(0) xsize(2) ysize(1) 
```

<img src="/figures/streamplot_tline3.png" width="100%">

```
streamplot value_real year if countrycode=="TSA", by(category) cat(splitvar) smooth(2) palette(tab Green-Orange-Teal) ///
	yline(0) xsize(2) ysize(1) tline 
```

<img src="/figures/streamplot_tline4.png" width="100%">

```
streamplot value_real year if countrycode=="TSA", by(category) cat(splitvar) smooth(2) palette(tab Nuriel Stone) ///
	yline(0) xsize(2) ysize(1) tline tlc(white) tlw(0.8) tlp(dash)	
```

<img src="/figures/streamplot_tline5.png" width="100%">

```
streamplot value_real year if countrycode=="TSA", by(category) cat(splitvar) smooth(2) palette(tab Green-Orange-Teal) ///
	yline(0) xsize(2) ysize(1) tline tlc(black) tlw(0.5) tlp(dash)	
```

<img src="/figures/streamplot_tline6.png" width="100%">

```
streamplot value_real year if countrycode=="TSA", by(category) cat(splitvar) smooth(2) palette(tab Green-Orange-Teal) ///
	yline(0) xsize(2) ysize(1) tline tlc(black) tlw(0.5) tlp(dash) xtitle("") ///
	xlabel(1990(2)2022, angle(90)) labsize(2.2) offset(8) 	///
	title("{fontface Arial Bold:GDP Expenditures in South Asia (Constant 2015 USD billions)}")	///
	note("World Bank Open Data.", size(2))
```

<img src="/figures/streamplot_tline7.png" width="100%">


## v1.8 updates

```stata
streamplot value_real year if countrycode=="TSA", by(category) cat(splitvar) smooth(2) palette(tab Green-Orange-Teal) ///
	yline(0) xsize(2) ysize(1) tline tlc(black) tlw(0.5) tlp(dash) xtitle("") xline(2020) ///
	xlabel(1990(2)2022, angle(90)) labsize(2.2) offset(8) labprop 	///
	title("{fontface Arial Bold:GDP Expenditures in South Asia (Constant 2015 USD billions)}")	///
	note("World Bank Open Data.", size(2))
```

<img src="/figures/streamplot_labprop1.png" width="100%">

```
streamplot value_real year  if countrycode=="TSA", by(category) smooth(2) palette(tab Green-Orange-Teal) ///
	xsize(2) ysize(1) xtitle("") ///
	xlabel(, angle(90)) labsize(2.2) offset(8) recenter(bottom)  labprop  	///
	title("{fontface Arial Bold:GDP Expenditures in South Asia (Constant 2015 USD billions)}")	///
	note("World Bank Open Data.", size(2)) 
```

<img src="/figures/streamplot_labprop2.png" width="100%">

```
streamplot value_real year  if countrycode=="TSA", by(category) smooth(2) palette(tab Green-Orange-Teal) ///
	xsize(2) ysize(1) xtitle("")  ///
	xlabel(, angle(90)) labsize(2.2) offset(8) recenter(bottom) labprop labcolor(palette)  	///
	title("{fontface Arial Bold:GDP Expenditures in South Asia (Constant 2015 USD billions)}")	///
	note("World Bank Open Data.", size(2)) 
```

<img src="/figures/streamplot_labprop3.png" width="100%">


## v1.81 stacked area graph

```
streamplot value_real year  if countrycode=="TSA", by(category) smooth(0) area recenter(bottom)  ///
	xsize(2) ysize(1) xtitle("") palette(tab Green-Orange-Teal)  ///
	xlabel(, angle(90)) labsize(2.2) offset(8)   	///
	title("{fontface Arial Bold:GDP Expenditures in South Asia (Constant 2015 USD billions)}")	///
	note("World Bank Open Data.", size(2))  
```

<img src="/figures/streamplot_labprop4.png" width="100%">


## Feedback

Please open an [issue](https://github.com/asjadnaqvi/stata-streamplot/issues) to report errors, feature enhancements, and/or other requests.


## Change log

**v1.9 (08 Feb 2025)**
- `droplow` has been taken out. All categories are now plotted even if they have one observation. If categories end in the middle, they are not labeled.
- The option `wrap` now requires the [graphfunctions](https://github.com/asjadnaqvi/stata-graphfunctions) package. Word boundaries are now respected.
- Fixed several bugs.

**v1.82 (10 Jun 2024)**
- Added `wrap()` option for label wrapping.
- Minor code fixes.

**v1.81 (30 Apr 2024)**
- Added `area` option to allow stacked area graphs.

**v1.8 (25 Apr 2024)**
- Added `labprop` and `labscale()` options to allow easy label scaling.
- Added `share` and `percent` as substitutes.
- Major code rework to optimize the speed of the graph generation.
- Generic twoway options added.
- 

**v1.7 (01 Apr 2024)**
- Added trendline options: `tline`, `tlcolor()`, `tlpattern()`, `tlwidth()`.
- Added additional checks for plotting data.
- Better handling of missing values and categories.

**v1.61 (15 Jan 2024)**
- Fixed issues with locals.
- Change `ylabcolor()` and `ylabsize()` to `labcolor()` and `labsize()` respectively.

**v1.6 (15 Oct 2023)**
- Major update with the `cat()` option added to compare top versus bottom streams.
- Option `yreverse` fixed.
- Option `nolab` fixed.
- Several internal routines rewritten and cleaned up.
- The option `percent()` is now defined in the 0-100 (or higher range). Changed from the 0-1 range.

**v1.52 (25 Aug 2023)**
- Support for `aspect()`, `saving()`, `xscale()`, and `graphregion()` added.

**v1.51 (28 May 2023)**
- Cleaned up `labcond()` to align it with other packages.
- `offset()` changed to percentages to align it with other packages.
- Minor code cleanups, updates to defaults, and help file.

**v1.5 (20 Nov 2022)**
- Option to recenter the graphs added. 
- Improve the precision of the calculations.

**v1.4 (08 Nov 2022)**
- Major code cleanup.
- The command now does error checks on the number of observations.
- The command now correct deals with sequence of variables.
- Additional `colorpalette` options added. 
- Several fixes to the help file.

**v1.3 (20 Jun 2022)**
- ado distribution date added.
- ylabel color, format, and percentages added (Thanks to Marc Kaulisch who suggested and contributed to these options).
- Fixes to variables precisions.
- y-label color fixed. Labels can either take on a named color, or they can be assigned the same colors as the color palette.

**v1.2 (06 Jun 2022)**
- Fixes to value labels no passing through to graphs (Thanks to Marc Kaulisch).
- Several graph options modified to passthru for better integration with twoway options.
- Smoothing parameter adjusted
- Error checks added. If there are too few observations per group, the command will abort.

**v1.1 (08 Apr 2022)**
- Public release. Several options and features added.

**v1.0 (06 Aug 2021)**
- Beta version

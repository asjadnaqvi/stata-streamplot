
![streamplot](https://github.com/asjadnaqvi/stata-streamplot/assets/38498046/4b7bbaab-8667-4f47-a119-ec93dcd607a3)

![StataMin](https://img.shields.io/badge/stata-2015-blue) ![issues](https://img.shields.io/github/issues/asjadnaqvi/stata-streamplot) ![license](https://img.shields.io/github/license/asjadnaqvi/stata-streamplot) ![Stars](https://img.shields.io/github/stars/asjadnaqvi/stata-streamplot) ![version](https://img.shields.io/github/v/release/asjadnaqvi/stata-streamplot) ![release](https://img.shields.io/github/release-date/asjadnaqvi/stata-streamplot)

---

[Installation](#Installation) | [Syntax](#Syntax) | [Examples](#Examples) | [Feedback](#Feedback) | [Change log](#Change-log)

---

# streamplot v1.61
(15 Jan 2024)

This package provides the ability to generate stream plots in Stata. It is based on the [Streamplot Guide](https://medium.com/the-stata-guide/covid-19-visualizations-with-stata-part-10-stream-graphs-9d55db12318a) (December 2020).


## Installation

The package can be installed via SSC or GitHub. The GitHub version, *might* be more recent due to bug fixes, feature updates etc, and *may* contain syntax improvements and changes in *default* values. See version numbers below. Eventually the GitHub version is published on SSC.

SSC (**v1.51**):
```
ssc install streamplot, replace
```

GitHub (**v1.61**):

```
net install streamplot, from("https://raw.githubusercontent.com/asjadnaqvi/stata-streamplot/main/installation/") replace
```



The `palettes` package is required to run this command:

```
ssc install palettes, replace
ssc install colrspace, replace
```

Even if you have these packages installed, please check for updates: `ado update, update`.

If you want to make a clean figure, then it is advisable to load a clean scheme. These are several available and I personally use the following:

```
ssc install schemepack, replace
set scheme white_tableau  
```

You can also push the scheme directly into the graph using the `scheme(schemename)` option. See the help file for details or the example below.

I also prefer narrow fonts in figures with long labels. You can change this as follows:

```
graph set window fontface "Arial Narrow"
```



## Syntax

The syntax for the latest version is as follows:

```
streamplot y x [if] [in], by(varname) 
            [ palette(str) smooth(num) labcond(str) offset(num) alpha(num) droplow yreverse cat(varname) recenter(top|mid|bot) 
               lcolor(str) lwidth(str) labsize(num) labcolor(color|palette) percent format(str) nolabel
               xlabel(str) xtitle(str) ytitle(str) title(str) subtitle(str) note(str) 
               ysize(num) xsize(num) scheme(str) aspect(str) name(str) saving(str)
            ]
```

See the help file `help streamplot` for details.

The most basic use is as follows:

```
streamplot y x, by(varname)
```

where `y` is the variable we want to plot, and `x` is usually the time dimension. The `by` variable splits the data into different groupings that also determines the colors. The color schemes can be modified using the `palettes(name)` option. Here any scheme from the `colorpalettes` package can be used.



## Examples

Set up the data:

```
clear
set scheme white_tableau
graph set window fontface "Arial Narrow"

use "https://github.com/asjadnaqvi/stata-streamplot/blob/main/data/streamdata.dta?raw=true", clear

```

We can generate basic graphs as follows:

```
streamplot new_cases date, by(region) 
```

<img src="/figures/streamplot1.png" height="600">

```
streamplot new_cases date if date > 22400, by(region) smooth(6)
```

<img src="/figures/streamplot2.png" height="600">

Recenter the graphs to top or bottom:

```
streamplot new_cases date if date > 22400, by(region) smooth(6) recenter(bot)
```

<img src="/figures/streamplot2_1.png" height="600">

```
streamplot new_cases date if date > 22400, by(region) smooth(6) recenter(top)
```

<img src="/figures/streamplot2_2.png" height="600">


```
streamplot new_cases date if date > 22400, by(region) smooth(6) ///
	labcond(20000) ylabsize(1.8) lc(black) lw(0.04)
```

<img src="/figures/streamplot3.png" height="600">


```
streamplot new_cases date if date > 22400, by(region) smooth(6) ///
	labcond(20000) ylabsize(1.8) lc(black) lw(0.04) format(%12.0fc) offset(20)
```

<img src="/figures/streamplot3_1.png" height="600">


```
streamplot new_cases date if date > 22400, by(region) smooth(6) palette(CET D11) ///
	labcond(2) ylabsize(1.8) lc(black) lw(0.04)  percent format(%3.2f) offset(20) ylabc(red)
```

<img src="/figures/streamplot3_2.png" height="600">

```
streamplot new_cases date if date > 22400, by(region) smooth(6) palette(CET C6, reverse) ///
	labcond(1) ylabsize(1.8) lc(black) lw(0.04)  percent format(%3.2f) offset(20) ylabc(palette)
```

<img src="/figures/streamplot3_3.png" height="600">


```
qui summ date if date > 22400

local xmin = `r(min)'
local xmax = `r(max)'

streamplot new_cases date if date > 22400, by(region) smooth(6) palette(CET D02)  ///
	title("My Stata stream plot") /// 
	subtitle("Subtitle here") note("Note here") ///
	labcond(20000) ylabsize(1.5) lc(white) lw(0.08) ///
	xlabel(`xmin'(20)`xmax', angle(90)) xtitle("")
```

<img src="/figures/streamplot4.png" height="600">




or a custom graph scheme:

```
streamplot new_cases date if date > 22600, by(region) smooth(6)  palette(CET CBD1)  ///
	title("My Stata stream plot", size(6)) subtitle("with colorblind-friendly colors", size(4))  ///
	labcond(20000) ylabs(2) lc(black) lw(0.03) offset(25) xtitle("") ///
	scheme(neon) 
```

where the dark background `neon` scheme is loaded from the [schemepack](https://github.com/asjadnaqvi/stata-schemepack) suite.


<img src="/figures/streamplot5.png" height="600">


## v1.6 updates

Test the `yreverse` option:

```
streamplot new_cases date if date > 22400, by(region) smooth(6) ///
	labcond(20000) ylabsize(1.8) lc(black) lw(0.04) format(%12.0fc) offset(20) yrev
```

<img src="/figures/streamplot6.png" height="600">


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

<img src="/figures/streamplot7.png" height="600">


We can use the new variable itself in the `by()` option:


```
streamplot new_cases date if date > 22400, cat(ns) by(ns) smooth(6) 
```

<img src="/figures/streamplot8.png" height="600">



## Feedback

Please open an [issue](https://github.com/asjadnaqvi/stata-streamplot/issues) to report errors, feature enhancements, and/or other requests.


## Change log

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

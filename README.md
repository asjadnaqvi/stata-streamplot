![StataMin](https://img.shields.io/badge/stata-2015-blue) ![issues](https://img.shields.io/github/issues/asjadnaqvi/stata-streamplot) ![license](https://img.shields.io/github/license/asjadnaqvi/stata-streamplot) ![Stars](https://img.shields.io/github/stars/asjadnaqvi/stata-streamplot) ![version](https://img.shields.io/github/v/release/asjadnaqvi/stata-streamplot) ![release](https://img.shields.io/github/release-date/asjadnaqvi/stata-streamplot)

# streamplot v1.2

This package provides the ability to generate stream plots in Stata. It is based on the [Streamplot Guide](https://medium.com/the-stata-guide/covid-19-visualizations-with-stata-part-10-stream-graphs-9d55db12318a) that I released in December 2020.


## Installation

The package can be installed via SSC or GitHub. The GitHub version, *might* be more recent due to bug fixes, feature updates etc, and *may* contain syntax improvements and changes in *default* values. See version numbers below. Eventually the GitHub version is published on SSC.

SSC (**v1.1**):
```
ssc install streamplot, replace
```

GitHub (**v1.2**):

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

The syntax is as follows:

```
streamplot y x [if] [in], by(varname) [ palette(str) smooth(num) labcond(str)
				lcolor(str) lwidth(str) xlabel(str)
				ylabsize(num)  ylabcolor(str) offset(num)
				title(str) subtitle(str) note(str) xsize(num) ysize(num) scheme(str) ]
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

use "https://github.com/asjadnaqvi/The-Stata-Guide/blob/master/data/OWID_data.dta?raw=true", clear

gen region = .
        replace region = 1 if group29==1 & country=="United States" // North America
        replace region = 2 if group29==1 & country!="United States" // North America
        replace region = 3 if group20==1 & country=="Brazil" // Latin America and Carribean
        replace region = 4 if group20==1 & country!="Brazil" // Latin America and Carribean
        replace region = 5 if group10==1 & country=="Germany" // Germany
        replace region = 6 if group10==1 & country!="Germany" // Rest of EU
        replace region = 7 if  group8==1 & group10!=1 & country=="United Kingdom" // Rest of Europe and Central Asia
        replace region = 8 if  group8==1 & group10!=1 & country!="United Kingdom" // Rest of Europe and Central Asia
        replace region = 9 if group26==1 // MENA
        replace region = 10 if group37==1 // Sub-saharan Africa
        replace region = 11 if group35==1 & country=="India" // South Asia
        replace region = 12 if group35==1 & country!="India" // South Asia
        replace region = 13 if  group6==1 // East Asia and Pacific


lab de region  1 "United States" 2 "Rest of North America" 3 "Brazil" 4 "Rest of Latin America" 5 "Germany" ///
                6 "Rest of European Union" 7 "United Kingdom" 8 "Rest of Europe" 9 "MENA" 10 "Sub-Saharan Africa" ///
                11 "India" 12 "Rest of South Asia" 13 "East Asia and Pacific"

lab val region region


keep date new_cases country region
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

```
streamplot new_cases date if date > 22400, by(region) smooth(6) ///
	title("My stream plot") note("test the note") ///
	labcond(> 100000) ylabsize(1.8) lc(black) lw(0.04)
```

<img src="/figures/streamplot3.png" height="600">

```
qui summ date if date > 22400

local xmin = `r(min)'
local xmax = `r(max)'

streamplot new_cases date if date > 22400, by(region) smooth(6) ///
	title("My stream plot") subtitle("Subtitle here") note("Note here") ///
	labcond(> 100000) ylabsize(1.5) lc(white) lw(0.08) ///
	xlabel(`xmin'(20)`xmax', angle(90)) xtitle("")
```

<img src="/figures/streamplot4.png" height="600">




or a custom graph scheme:

```
streamplot new_cases date if date > 22400, by(region) smooth(6) ///
	title("My stream plot", size(6)) subtitle("Subtitle here", size(4))  ///
	labcond(> 100000) ylabs(2) lc(black) lw(0.02) offset(0.3) xtitle("") ///
	scheme(neon)
```

where the dark background `neon` scheme is loaded from the [schemepack](https://github.com/asjadnaqvi/Stata-schemes) suite.


<img src="/figures/streamplot5.png" height="600">

## Feedback

Please open an [issue](https://github.com/asjadnaqvi/stata-streamplot/issues) to report errors, feature enhancements, and/or other requests.


## Versions

**v1.2 (06 Jun 2022)**
- Fixes to value labels no passing through to graphs (Thanks to Marc Kaulisch)
- Several graph options modified to passthru for better integration with twoway options.
- Smoothing parameter adjusted
- Error checks added. If there are too few observations per group, the command will abort.

**v1.1 (08 Apr 2022)**
- Public release. Several options and features added.

**v1.0 (06 Aug 2021)**
- Beta version

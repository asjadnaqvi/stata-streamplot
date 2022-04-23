![StataMin](https://img.shields.io/badge/stata-2015-blue) ![issues](https://img.shields.io/github/issues/asjadnaqvi/stata-streamplot) ![license](https://img.shields.io/github/license/asjadnaqvi/stata-streamplot) ![Stars](https://img.shields.io/github/stars/asjadnaqvi/stata-streamplot) ![version](https://img.shields.io/github/v/release/asjadnaqvi/stata-streamplot) ![release](https://img.shields.io/github/release-date/asjadnaqvi/stata-streamplot)

# streamplot v1.1

This package provides the ability to generate stream plots in Stata. It is based on the [Streamplot Guide](https://medium.com/the-stata-guide/covid-19-visualizations-with-stata-part-10-stream-graphs-9d55db12318a) that I released in December 2020.


## Installation

The package is available on SSC and can be installed as follows:
```
ssc install streamplot, replace
```

Or it can be installed from GitHub:

```
net install streamplot, from("https://raw.githubusercontent.com/asjadnaqvi/stata-streamplot/main/installation/") replace
```

The GitHub version, *might* be more recent due to bug fixes, feature updates etc.

The `palettes` package is required to run this command:

```
ssc install palettes, replace
ssc install colrspace, replace
```

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
streamplot y x [if] [in], by(varname) [ palette(string) smooth(num) labcond(string) 
                        lcolor(string) lwidth(string) xticks(string) xlabsize(num) ylabsize(num)
                        xlabcolor(str) ylabcolor(str) xlinewidth(string) xlinecolor(string) 
                        title(string) subtitle(string) note(string) scheme(str) ]
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
streamplot new_cases date if date > 22400, by(region) palette(scico corko) lw(0.02)
```

<img src="/figures/streamplot2.png" height="600">

```
streamplot new_cases date, by(region) xlinew(medium)
```

<img src="/figures/streamplot3.png" height="600">

```
streamplot new_cases date, by(region) xlinec(none)
```

<img src="/figures/streamplot4.png" height="600">


We can add additional options, for example, conditional labeling:

```
streamplot new_cases date if date > 22400, by(region) smooth(5) ///
        title("My stream plot") note("test the note") ///
        labcond(> 100000) ylabsize(1.8) lc(black) lw(0.08)
```

<img src="/figures/streamplot5.png" height="600">

Custom x-axis:

```
qui summ date if date > 22400

local xmin = r(min)
local xmax = r(max) + 40

streamplot new_cases date if date > 22400, by(region) smooth(3) ///
        title("My stream plot") subtitle("Subtitle here") note("Note here") ///
        labcond(> 100000) ylabsize(1.5) xlabc(blue) ylabc(orange) lc(white) lw(0.08) ///
        xticks(`xmin'(20)`xmax')
```

<img src="/figures/streamplot6.png" height="600">

or a custom graph scheme:

```
streamplot new_cases date if date > 22400, by(region) ///
        title("My stream plot", size(6)) subtitle("Subtitle here", size(4)) note("Note here") ///
        labcond(> 100000) ylabs(2.1) lc(black) lw(0.02) ///
        scheme(neon) xlinec(gs4) 
```

where the dark background `neon` scheme is loaded from the [schemepack](https://github.com/asjadnaqvi/Stata-schemes) suite.


<img src="/figures/streamplot7.png" height="600">

## Feedback

Please open an [issue](https://github.com/asjadnaqvi/stata-streamplot/issues) to report errors, feature enhancements, and/or other requests. 


## Versions

**v1.1 (08 Apr 2022)**
- Public release. Several options and features added.

**v1.0 (06 Aug 2021)**
- Beta version






{smcl}
{* 08April2022}{...}
{hi:help streamplot}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-streamplot":streamplot v1.1 (GitHub)}}

{hline}

{title:streamplot}: A Stata package for streamplots. 

{p 4 4 2}
The command is based on the following guide on Medium: {browse "https://medium.com/the-stata-guide/covid-19-visualizations-with-stata-part-10-stream-graphs-9d55db12318a":Stream plots}.


{marker syntax}{title:Syntax}
{p 8 15 2}

{cmd:streamplot} {it:y x} {ifin}, {cmd:by}(varname) {cmd:[} {cmd:palette}(string) {cmd:smooth}(num) {cmd:labcond}(string) 
			{cmdab:lc:olor}(string) {cmdab:lw:idth}(string) {cmd:xticks}(string) {cmdab:xlabs:ize}({it:num}) {cmdab:ylabs:ize}({it:num})
			{cmdab:xlabc:olor}({it:str}) {cmdab:ylabc:olor}({it:str}) {cmdab:xlinew:idth}(string) {cmdab:xlinec:olor}(string) 
			{cmd:title}(string) {cmd:subtitle}(string) {cmd:note}(string) {cmd:scheme}({it:str}) {cmd:]}


{p 4 4 2}
The options are described as follows:

{synoptset 36 tabbed}{...}
{synopthdr}
{synoptline}

{p2coldent : {opt streamplot y x}}The command requires a numeric {it:y} variable and a numeric {it:x} variable. The x variable is usually a time variable.{p_end}

{p2coldent : {opt by(group variable)}}This is the group variable that defines the layers.{p_end}

{p2coldent : {opt palette(string)}}Color name is any named scheme defined in the {stata help colorpalette:colorpalette} package. Default is {stata colorpalette CET C6:{it:CET C6}}.{p_end}

{p2coldent : {opt smooth(value)}}The data is smoothed based on a number of past observations. The default value 6. A value of 0 implies no smoothing.{p_end}

{p2coldent : {opt labcond(string)}}Labels have the group name and the value of the last observation in brackets. The label condition can be used to limit the number of labels shown. 
For example if we want to label only values which are greater than a certain threhold, then we can write {it:labcond(>= 10000)}. Currently only one condition is supported. 
Here the main aim is to clean up the figure especially if labels are bunched on top of each other. See example below.{p_end}

{p2coldent : {opt xticks(string)}}This option can be used for customizing the x-axis ticks. See example below.{p_end}

{p2coldent : {opt lw:idth(value)}}The line width of the area stroke. The default is {it:0.02}.{p_end}

{p2coldent : {opt lc:olor(string)}}The line color of the area stroke. The default is {it:white}.{p_end}

{p2coldent : {opt xlinew:idth(string)}}The width of the verticle grid lines.{p_end}

{p2coldent : {opt xlinec:olor(string)}}The color of the verticle grid lines.{p_end}

{p2coldent : {opt xlabs:ize(value)}, {opt ylabsize(value)}}The size of the x and y-axis labels. Defaults are {it:2} and {it:1.4} respectively.{p_end}

{p2coldent : {opt xlabc:olor(string)}, {opt ylabc:olor(string)}}This option can be used for customizing the x and y-axis label colors especially if non-standard graph schemes are used. Defaults are {it:black}.{p_end}

{p2coldent : {opt title, subtitle, note}}These are standard twoway graph options.{p_end}

{p2coldent : {opt scheme(string)}}Load the custom scheme. Above options can be used to fine tune individual elements.{p_end}

{synoptline}
{p2colreset}{...}


{title:Dependencies}

The {browse "http://repec.sowi.unibe.ch/stata/palettes/index.html":palette} package (Jann 2018) is required for {cmd:streamplot}:

{stata ssc install palettes, replace}
{stata ssc install colrspace, replace}


{title:Examples}

Load the data and clean it up:
use "https://github.com/asjadnaqvi/The-Stata-Guide/blob/master/data/OWID_data.dta?raw=true", clear

keep date new_cases country

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

- Basic use:

streamplot new_cases date, by(region)

streamplot new_cases date if date > 22400, by(region) palette(twilight) 

streamplot new_cases date, by(region) xlinew(medium)

streamplot new_cases date, by(region) xlinec(none)

- With additional options:

{it:Condition labels}

streamplot new_cases date if date > 22400, by(region) smooth(5) ///
	title("My stream plot") note("test the note") ///
	labcond(> 100000) ylabsize(1.8) lc(black) lw(0.08)


{it:Condition x-axis}

qui summ date if date > 22400

local xmin = r(min)
local xmax = r(max) + 40

streamplot new_cases date if date > 22400, by(region) smooth(3) ///
	title("My stream plot") subtitle("Subtitle here") note("Note here") ///
	labcond(> 100000) ylabsize(1.5) xlabc(blue) ylabc(orange) lc(white) lw(0.08) ///
	xticks(`xmin'(20)`xmax')

{it:Custom graph scheme}

The example below uses the {stata ssc install schemepack, replace:schemepack} suite and loads the {stata set scheme neon:neon} which has a black background. Here we need to fix some colors:

streamplot new_cases date if date > 22400, by(region) ///
	title("My stream plot", size(6)) subtitle("Subtitle here", size(4)) note("Note here") ///
	labcond(> 100000) ylabs(2.1) lc(black) lw(0.02) ///
	scheme(neon) xlinec(gs4) 

{hline}

{title:Package details}

Version      : {bf:streamplot} v1.1
This release : 08 Apr 2022
First release: 06 Aug 2021
Repository   : {browse "https://github.com/asjadnaqvi/streamplot":GitHub}
Keywords     : Stata, graph, stream plot
License      : {browse "https://opensource.org/licenses/MIT":MIT}

Author       : {browse "https://github.com/asjadnaqvi":Asjad Naqvi}
E-mail       : asjadnaqvi@gmail.com
Twitter      : {browse "https://twitter.com/AsjadNaqvi":@AsjadNaqvi}



{title:References}

{p 4 8 2}Jann, B. (2018). {browse "https://www.stata-journal.com/article.html?article=gr0075":Color palettes for Stata graphics}. The Stata Journal 18(4): 765-785.



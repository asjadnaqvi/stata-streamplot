{smcl}
{* 20June2022}{...}
{hi:help streamplot}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-streamplot":streamplot v1.3 (GitHub)}}

{hline}

{title:streamplot}: A Stata package for streamplots. 

{p 4 4 2}
The command is based on the following guide on Medium: {browse "https://medium.com/the-stata-guide/covid-19-visualizations-with-stata-part-10-stream-graphs-9d55db12318a":Stream plots}.


{marker syntax}{title:Syntax}
{p 8 15 2}

{cmd:streamplot} {it:y x} {ifin}, {cmd:by}(varname) {cmd:[} {cmd:palette}({it:str}) {cmd:smooth}({it:num}) {cmd:labcond}({it:str}) {cmd:offset}({it:num}) 
			{cmdab:lc:olor}({it:str}) {cmdab:lw:idth}({it:str}) {cmdab:ylabs:ize}({it:num}) {cmdab:ylabc:olor}({it:str}) {cmd:percent} {cmd:format}({it:str})
			{cmd:xlabel}({it:str}) {cmd:xtitle}({it:str}) {cmd:ytitle}({it:str}) {cmd:title}({it:str}) {cmd:subtitle}({it:str}) {cmd:note}({it:str}) 
			{cmd:ysize}({it:num}) {cmd:xsize}({it:num}) {cmd:scheme}({it:str}) {cmd:]}


{p 4 4 2}
The options are described as follows:

{synoptset 36 tabbed}{...}
{synopthdr}
{synoptline}

{p2coldent : {opt streamplot y x}}The command requires a numeric {it:y} variable and a numeric {it:x} variable. The x variable is usually a time variable.{p_end}

{p2coldent : {opt by(group variable)}}This is the group variable that defines the layers.{p_end}

{p2coldent : {opt palette(string)}}Color name is any named scheme defined in the {stata help colorpalette:colorpalette} package. Default is {stata colorpalette CET C6:{it:CET C6}}.{p_end}

{p2coldent : {opt smooth(value)}}The data is smoothed based on a number of past observations. The default value is {it:2}. A value of 0 implies no smoothing.{p_end}

{p2coldent : {opt offset(value)}}Extends the x-axis range to accommodate labels. The default value is {it:0.12} or 12% of {it:xmax-xmin}.{p_end}

{p2coldent : {opt percent}}Shows the percentage share for the y-axis categories.{p_end}

{p2coldent : {opt format()}}Format the values of the y-axis category.{p_end}

{p2coldent : {opt xlabel()}}This is the standard twoway graph option for labeling and formatting the x-axis. {p_end}

{p2coldent : {opt labcond(string)}}Labels have the group name and the value of the last observation in brackets. The label condition can be used to limit the number of labels shown. 
For example if we want to label only values which are greater than a certain threhold, then we can write {it:labcond(>= 10000)}. Currently only one condition is supported. 
Here the main aim is to clean up the figure especially if labels are bunched on top of each other. See example below.{p_end}

{p2coldent : {opt lw:idth(value)}}The line width of the area stroke. The default is {it:0.02}.{p_end}

{p2coldent : {opt lc:olor(string)}}The line color of the area stroke. The default is {it:white}.{p_end}

{p2coldent : {opt xtitle, ytitle, xsize, ysize}}These are standard twoway graph options.{p_end}

{p2coldent : {opt title, subtitle, note}}These are standard twoway graph options.{p_end}

{p2coldent : {opt scheme(string)}}Load the custom scheme. Above options can be used to fine tune individual elements.{p_end}

{synoptline}
{p2colreset}{...}


{title:Dependencies}

The {browse "http://repec.sowi.unibe.ch/stata/palettes/index.html":palette} package (Jann 2018) is required for {cmd:streamplot}:

{stata ssc install palettes, replace}
{stata ssc install colrspace, replace}

Even if you have these installed, it is highly recommended to check for updates: {stata ado update, update}

{title:Examples}

{ul:{it:Set up the data}}

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

{ul:{it:Basic use}}

- {stata streamplot new_cases date, by(region)}

- {stata streamplot new_cases date if date > 22400, by(region) smooth(6)}

- streamplot new_cases date if date > 22400, by(region) smooth(6) ///
	title("My stream plot") note("test the note") ///
	labcond(> 100000) ylabsize(1.8) lc(black) lw(0.04)

- qui summ date if date > 22400
	local xmin = `r(min)'
	local xmax = `r(max)'

  streamplot new_cases date if date > 22400, by(region) smooth(6) ///
	title("My stream plot") subtitle("Subtitle here") note("Note here") ///
	labcond(> 100000) ylabsize(1.5) lc(white) lw(0.08) ///
	xlabel(`xmin'(20)`xmax', angle(90)) xtitle("")

Here we use the custom scheme {it:neon} from {stata help schemepack:schemepack} ({stata ssc install schemepack, replace:{it:install}}):

- streamplot new_cases date if date > 22400, by(region) smooth(6) ///
	title("My stream plot", size(6)) subtitle("Subtitle here", size(4))  ///
	labcond(> 100000) ylabs(2) lc(black) lw(0.02) offset(0.3) xtitle("") ///
	scheme(neon) 

{hline}

{title:Acknowledgements}

Marc Kaulisch found an error in the smoothing parameter and value labels. Marc also suggested several enhancements and contributed to the package.


{title:Package details}

Version      : {bf:streamplot} v1.3
This release : 20 Jun 2022
First release: 06 Aug 2021
Repository   : {browse "https://github.com/asjadnaqvi/streamplot":GitHub}
Keywords     : Stata, graph, stream plot
License      : {browse "https://opensource.org/licenses/MIT":MIT}

Author       : {browse "https://github.com/asjadnaqvi":Asjad Naqvi}
E-mail       : asjadnaqvi@gmail.com
Twitter      : {browse "https://twitter.com/AsjadNaqvi":@AsjadNaqvi}



{title:References}

{p 4 8 2}Jann, B. (2018). {browse "https://www.stata-journal.com/article.html?article=gr0075":Color palettes for Stata graphics}. The Stata Journal 18(4): 765-785.



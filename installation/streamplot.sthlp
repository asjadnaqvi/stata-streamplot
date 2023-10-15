{smcl}
{* 15Oct2023}{...}
{hi:help streamplot}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-streamplot":streamplot v1.6 (GitHub)}}

{hline}

{title:streamplot}: A Stata package for stream plots. 

{p 4 4 2}
The command is based on the following guide on Medium: {browse "https://medium.com/the-stata-guide/covid-19-visualizations-with-stata-part-10-stream-graphs-9d55db12318a":Stream plots}.


{marker syntax}{title:Syntax}
{p 8 15 2}

{cmd:streamplot} {it:y x} {ifin}, {cmd:by}(varname) 
            {cmd:[} {cmd:palette}({it:str}) {cmd:smooth}({it:num}) {cmd:labcond}({it:str}) {cmd:offset}({it:num}) {cmd:alpha}({it:num}) {cmd:droplow} {cmdab:yrev:erse} {cmd:cat}({it:varname}) {cmdab:rec:enter}(top|mid|bot) 
               {cmdab:lc:olor}({it:str}) {cmdab:lw:idth}({it:str}) {cmdab:ylabs:ize}({it:num}) {cmdab:ylabc:olor}({it:color}|{it:palette}) {cmd:percent} {cmd:format}({it:str}) {cmdab:nolab:el}
               {cmd:xlabel}({it:str}) {cmd:xtitle}({it:str}) {cmd:ytitle}({it:str}) {cmd:title}({it:str}) {cmd:subtitle}({it:str}) {cmd:note}({it:str}) 
               {cmd:ysize}({it:num}) {cmd:xsize}({it:num}) {cmd:scheme}({it:str}) {cmd:aspect}({it:str}) {cmd:name}({it:str}) {cmd:saving}({it:str})
            {cmd:]}


{p 4 4 2}
The options are described as follows:

{synoptset 36 tabbed}{...}
{synopthdr}
{synoptline}

{p2coldent : {opt streamplot y x}}The command requires a numeric {it:y} variable and a numeric {it:x} variable. The x variable is usually a time variable.{p_end}

{p2coldent : {opt by(var)}}This is the group variable that defines the layers.{p_end}

{p2coldent : {opt cat(var)}}This is a binary variable that defines the split above and below the y = 0 axis. Useful for comparise {opt by()} variables across two categories.
Note that defining {opt cat()} overwrites the {opt recenter()} option explained below.{p_end}

{p2coldent : {opt rec:enter(top|mid|bot)}}This option changes where the graph is recentered. The default option is {opt rec:enter(middle)}. 
Additional options are {opt rec:enter(top)} or {opt rec:enter(bottom)}. 
For brevity, the following can be specified: {it:middle} = {it:mid} = {it:m}, {it:top} = {it:t}, {it:bottom} = {it:bot} = {it:b}.{p_end}

{p2coldent : {opt yrev:erse}}Reverse the variable labels.{p_end}

{p2coldent : {opt nolab:el}}Hide the variable labels.{p_end}

{p2coldent : {opt droplow}}If there are fewer than 10 observations per {opt by()} variable, the command will give an error. If only some groups have this issue, 
then use the {opt droplow} option to drop these observations. If all groups have few observations, then {cmd:streamplot} cannot be used.{p_end}

{p2coldent : {opt smooth(num)}}The smoothing parameter defined in terms of last observations to use. The default value is {opt smooth(3)}.
A value of 0 implies no smoothing.{p_end}

{p2coldent : {opt palette(str)}}Color name is any named scheme defined in the {stata help colorpalette:colorpalette} package.
Default is {stata colorpalette tableau:{it:tableau}}.{p_end}

{p2coldent : {opt alpha(num)}}The transparency of area fills. The default value is {opt alpha(100)}. It is better to leave this option as it is.{p_end}

{p2coldent : {opt offset(num)}}Extends the x-axis range to accommodate labels. The default value is {opt offset(15)} for 15% of {it:xmax-xmin} of the axis range.{p_end}

{p2coldent : {opt ylabc:olor(str)}}Either takes on a named Stata color, e.g. {opt ylabc(red)} for red labels.
If {it:ylabc(palette)} is specified, labels are colored based on the color palette.{p_end}

{p2coldent : {opt ylabs:ize(str)}}Size of the stream labels. Default value is {opt ylabs(1.4)}.{p_end}

{p2coldent : {opt percent}}Shows the percentage share for the y-axis categories.{p_end}

{p2coldent : {opt format()}}Format the values of the y-axis category. Default value is {opt format(%12.0f)}.{p_end}

{p2coldent : {opt xlabel()}}This is the standard twoway graph option for labeling and formatting the x-axis. {p_end}

{p2coldent : {opt labcond(num)}}The label condition can be used to limit the number of labels shown. 
For example, {opt labcond(100)} will only shows labels where the last value is greater than 100.{p_end}

{p2coldent : {opt lw:idth(str)}}The line width of the area stroke. The default is {opt lw(0.05)}.{p_end}

{p2coldent : {opt lc:olor(str)}}The line color of the area stroke. The default is {opt lc(white)}.{p_end}

{p2coldent : {opt xtitle(), ytitle(), xsize(), ysize()}}These are standard twoway graph options.{p_end}

{p2coldent : {opt title(), subtitle(), note(), name()}}These are standard twoway graph options.{p_end}

{p2coldent : {opt scheme(string)}}Load the custom scheme. Above options can be used to fine tune individual elements.{p_end}

{synoptline}
{p2colreset}{...}


{title:Dependencies}

The {browse "http://repec.sowi.unibe.ch/stata/palettes/index.html":palette} package (Jann 2018, 2022) is required for {cmd:streamplot}:

{stata ssc install palettes, replace}
{stata ssc install colrspace, replace}

Even if you have these installed, it is highly recommended to check for updates: {stata ado update, update}

{title:Examples}

See {browse "https://github.com/asjadnaqvi/stata-streamplot":GitHub}.

{hline}


{title:Package details}

Version      : {bf:streamplot} v1.6
This release : 15 Oct 2023
First release: 06 Aug 2021
Repository   : {browse "https://github.com/asjadnaqvi/stata-streamplot":GitHub}
Keywords     : Stata, graph, stream plot
License      : {browse "https://opensource.org/licenses/MIT":MIT}

Author       : {browse "https://github.com/asjadnaqvi":Asjad Naqvi}
E-mail       : asjadnaqvi@gmail.com
Twitter      : {browse "https://twitter.com/AsjadNaqvi":@AsjadNaqvi}


{title:References}

{p 4 8 2}Jann, B. (2018). {browse "https://www.stata-journal.com/article.html?article=gr0075":Color palettes for Stata graphics}. The Stata Journal 18(4): 765-785.

{p 4 8 2}Jann, B. (2022). {browse "https://ideas.repec.org/p/bss/wpaper/43.html":Color palettes for Stata graphics: An update}. University of Bern Social Sciences Working Papers No. 43. 


{title:Other visualization packages}

{psee}
    {helpb arcplot}, {helpb alluvial}, {helpb bimap}, {helpb bumparea}, {helpb bumpline}, {helpb circlebar}, {helpb circlepack}, {helpb clipgeo}, {helpb delaunay}, {helpb joyplot}, 
	{helpb marimekko}, {helpb sankey}, {helpb schemepack}, {helpb spider}, {helpb streamplot}, {helpb sunburst}, {helpb treecluster}, {helpb treemap}


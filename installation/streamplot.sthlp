{smcl}
{* 08Feb2025}{...}
{hi:help streamplot}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-streamplot":streamplot v1.9 (GitHub)}}

{hline}

{title:streamplot}: A Stata package for stream plots. 

{p 4 4 2}
The command is based on the following guide on Medium: {browse "https://medium.com/the-stata-guide/covid-19-visualizations-with-stata-part-10-stream-graphs-9d55db12318a":Stream plots}.


{marker syntax}{title:Syntax}
{p 8 15 2}

{cmd:streamplot} {it:y x} {ifin}, {cmd:by}(varname) 
            {cmd:[} {cmd:palette}({it:str}) {cmd:smooth}({it:num}) {cmd:labcond}({it:str}) {cmd:offset}({it:num}) {cmd:alpha}({it:num}) {cmdab:yrev:erse} {cmd:cat}({it:varname}) 
               {cmdab:rec:enter}({it:top}|{it:mid}|{it:bot}) {cmdab:lc:olor}({it:str}) {cmdab:lw:idth}({it:str}) {cmdab:labs:ize}({it:num}) {cmdab:labc:olor}({it:color}|{it:palette})
               {cmd:percent} {cmd:format}({it:str}) {cmdab:area} {cmdab:nolab:el} {cmd:wrap}({it:num}) {cmd:tline} {cmdab:tlc:olor}({it:str}) {cmdab:tlw:idth}({it:str}) 
               {cmdab:tlp:attern}({it:str}) {cmd:yline}({it:str}) {cmdab:laboff:set}({it:num})  {cmd:labprop} {cmd:labscale}({it:num}) {cmd:wrap}({it:num}) {cmd:*}
            {cmd:]}


{p 4 4 2}
The options are described as follows:

{synoptset 36 tabbed}{...}
{synopthdr}
{synoptline}

{p2coldent : {opt streamplot y x}}The command requires a numeric {it:y} variable and a numeric {it:x} variable. The x variable is usually a time variable.{p_end}

{p2coldent : {opt by(var)}}This is the group variable that defines the layers.{p_end}

{p2coldent : {opt cat(var)}}This is a binary variable that defines the split above and below the y=0 axis. Useful for comparise {opt by()} variables across two categories.
Note that defining {opt cat()} overwrites the {opt recenter()} option explained below.{p_end}

{p2coldent : {opt rec:enter(top|mid|bot)}}This option changes where the graph is recentered. The default option is {opt rec:enter(middle)}. 
Additional options are {opt rec:enter(top)} or {opt rec:enter(bottom)}. 
For brevity, the following can be specified: {it:middle} = {it:mid} = {it:m}, {it:top} = {it:t}, {it:bottom} = {it:bot} = {it:b}.{p_end}

{p2coldent : {opt yrev:erse}}Reverse the variable labels.{p_end}

{p2coldent : {opt nolab:el}}Hide the variable labels.{p_end}

{p2coldent : {opt area}}Show stacked area graph. Options {opt recenter(bottom)} and {opt smooth(0)} are recommended with this option.{p_end}

{p2coldent : {opt smooth(num)}}The smoothing parameter defined in terms of last observations to use. The default value is {opt smooth(3)}.
A value of 0 implies no smoothing.{p_end}

{p2coldent : {opt palette(str)}}Color name is any named scheme defined in the {stata help colorpalette:colorpalette} package.
Default is {stata colorpalette tableau:{it:tableau}}.{p_end}

{p2coldent : {opt alpha(num)}}The transparency of area fills. The default value is {opt alpha(100)}. It is better to leave this option as it is.{p_end}

{p2coldent : {opt offset(num)}}Extends the x-axis range to accommodate labels. The default value is {opt offset(15)} for 15% of {it:xmax-xmin} of the axis range.{p_end}

{p2coldent : {opt wrap(num)}}Wrap the labels after a specific number of characters. Word boundaries are respected. Requires the latest {stata help graphfunctions:graphfunctions} package.{p_end}

{p2coldent : {opt labc:olor(str)}}Label colors are either defined as a single color, e.g. default is {opt labc(black)}. Or if {opt labc(palette)} is specified,
labels have the {opt palette()} colors.{p_end}

{p2coldent : {opt labs:ize(str)}}Size of the stream labels. The default value is {opt labs(1.4)}.{p_end}

{p2coldent : {opt percent}}Shows the percentage share for the y-axis categories.{p_end}

{p2coldent : {opt format(fmt)}}Format the values of the y-axis category. The default is {opt format(%12.0f)}.{p_end}

{p2coldent : {opt laboff:set(num)}}Offset the stream labels. Negative values will offset towards the left. The default is {opt laboff(0)}.{p_end}

{p2coldent : {opt labcond(num)}}The label condition can be used to limit the number of labels shown. 
For example, {opt labcond(100)} will only shows labels where the last data point value is greater than 100.{p_end}

{p2coldent : {opt lw:idth(str)}}The line width of the area stroke. The default is {opt lw(0.05)}.{p_end}

{p2coldent : {opt lc:olor(str)}}The line color of the area stroke. The default is {opt lc(white)}.{p_end}

{p2coldent : {opt tline}}Add a timeline which is the running sum of all the layers. Helpful for showing aggregates if {opt cat()} is used.{p_end}

{p2coldent : {opt tlw:idth(str)}}The timeline width. The default is {opt tlw(0.3)}.{p_end}

{p2coldent : {opt tlc:olor(str)}}The timeline color. The default is {opt tlc(black)}.{p_end}

{p2coldent : {opt tlp:attern(str)}}The timeline pattern. The default is {opt tlp(solid)}.{p_end}

{p2coldent : {opt labprop}}Scale the bar labels based on the relative values.{p_end}

{p2coldent : {opt labscale(num)}}Scale factor of {opt labprop}. Default value is {opt labscale(0.3333)}. Values closer to zero result in more exponential scaling, while values closer
to one are almost linear scaling. This is an advanced option so use carefully.{p_end}

{p2coldent : {opt *}}All other standard twoway options.{p_end}

{hline}

{title:Dependencies}

{stata ssc install palettes, replace}
{stata ssc install colrspace, replace}
{stata ssc install graphfunctions, replace}


{title:Examples}

See {browse "https://github.com/asjadnaqvi/stata-streamplot":GitHub}.


{title:Feedback}

Please submit bugs, errors, feature requests on {browse "https://github.com/asjadnaqvi/stata-streamplot/issues":GitHub} by opening a new issue.


{title:Citation guidelines}

See {browse "https://ideas.repec.org/c/boc/bocode/s459060.html"} for the official SSC citation. 
Please note that the GitHub version might be newer than the SSC version.


{title:Package details}

Version      : 1.9
This release : 08 Feb 2025
First release: 06 Aug 2021
Repository   : {browse "https://github.com/asjadnaqvi/stata-streamplot":GitHub}
Keywords     : Stata, graph, streamplot
License      : {browse "https://opensource.org/licenses/MIT":MIT}

Author       : {browse "https://github.com/asjadnaqvi":Asjad Naqvi}
E-mail       : asjadnaqvi@gmail.com
Twitter/X    : {browse "https://x.com/AsjadNaqvi":@AsjadNaqvi}
BlueSky      : {browse "https://bsky.app/profile/asjadnaqvi.bsky.social":@asjadnaqvi.bsky.social}


{title:References}

{p 4 8 2}Jann, B. (2018). {browse "https://www.stata-journal.com/article.html?article=gr0075":Color palettes for Stata graphics}. The Stata Journal 18(4): 765-785.

{p 4 8 2}Jann, B. (2022). {browse "https://ideas.repec.org/p/bss/wpaper/43.html":Color palettes for Stata graphics: An update}. University of Bern Social Sciences Working Papers No. 43. 


{title:Other visualization packages}
{psee}
    {helpb arcplot}, {helpb alluvial}, {helpb bimap}, {helpb bumparea}, {helpb bumpline}, {helpb circlebar}, {helpb circlepack}, {helpb clipgeo}, {helpb delaunay}, {helpb graphfunctions}, {helpb geoboundary}, {helpb geoflow}, {helpb joyplot}, 
	{helpb marimekko}, {helpb polarspike}, {helpb sankey}, {helpb schemepack}, {helpb spider}, {helpb splinefit}, {helpb streamplot}, {helpb sunburst}, {helpb ternary}, {helpb treecluster}, {helpb treemap}, {helpb trimap}, {helpb waffle}

Visit {browse "https://github.com/asjadnaqvi":GitHub} for further information.
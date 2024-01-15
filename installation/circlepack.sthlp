{smcl}
{* 15Jan2024}{...}
{hi:help circlepack}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-circlepack":circlepack v1.2 (GitHub)}}

{hline}


{title:circlepack}: A Stata package for hierarchical {browse "https://en.wikipedia.org/wiki/Circle_packing":circle packing}. 

This program implements the {it:A1.0} algorithm (Huang et. al. 2006) based on D3's {browse "https://observablehq.com/@d3/d3-packenclose":packEnclose} and Python's {browse "https://github.com/elmotec/circlify":circlify} routines.


{marker syntax}{title:Syntax}
{p 8 15 2}

{cmd:circlepack} {it:numvar} {ifin}, {cmd:by}({it:variables (min=1, max=3})) 
        {cmd:[} {cmd:pad}({it:num}) {cmd:points}({it:num}) {cmd:angle}({it:num}) {cmd:circle0} {cmd:circle0c}(str) {cmd:format}(str) {cmd:palette}(string) {cmd:share} 
          {cmd:labprop} {cmd:titleprop} {cmd:labscale}({it:num}) {cmdab:thresh:old}({it:num}) {cmd:fi}({it:list}) {cmdab:addt:itles} {cmdab:noval:ues} {cmdab:nolab:els} {cmdab:labs:ize}({it:num}) 
          {cmd:title}({it:str}) {cmd:subtitle}({it:str}) {cmd:note}({it:str}) {cmd:scheme}({it:str}) {cmd:name}({it:str}) {cmd:]}


{p 4 4 2}
The options are described as follows:

{synoptset 36 tabbed}{...}
{synopthdr}
{synoptline}

{p2coldent : {opt circlepack} {it:numvar}}The command requires a {it:numeric variable} that contains the values.{p_end}

{p2coldent : {opt by(group vars)}}At least one {it:by()} string variable needs to be specified, and a maximum of three string variables are allowed. These also are used as labels.
The order is parent layer first followed by child layer or more aggregated layers should be specified first.{p_end}

{p2coldent : {opt pad(num)}}Add padding to the circles. Default value is {it:0.1}. A value of 0 implies no padding.{p_end}

{p2coldent : {opt points(num)}}Number of points to define the circles. Default value is {it:60}. A value of 3 = triangles, 6 = hexagons, 8 = octagons, etc. 
If you are exporting a very large impact, value > 60 is recommended for smoother circles.{p_end}

{p2coldent : {opt angle(num)}}Angle of the points. Default value is {it:0}. Any value specified here will rotate the points on the circle. 
For example, if you draw hexagons, you can rotate the shapes using this option.{p_end}

{p2coldent : {opt thresh:old(num)}}The value below which categories are combined in a "Rest of ..." category. Default is {opt thresh(0)}.{p_end}

{p2coldent : {opt labcond(value)}}The minimum value for showing the value labels. For example, {opt labcond(20)} will only plot values greater than 20.{p_end}

{p2coldent : {opt format(fmt)}}Format the values of the labels. The default option is {opt format(%12.0fc)} for values and {opt format(%5.2f)} for the {opt percent} option.{p_end}

{p2coldent : {opt share}}Show percentage shares of the total instead of the actual values for all the layers.{p_end}

{p2coldent : {opt circle0}}Drawing the bounding circle.{p_end}

{p2coldent : {opt circle0c(str)}}Define the bounding circle color.{p_end}

{p2coldent : {opt palette(str)}}Color name is any named scheme defined in the {stata help colorpalette:colorpalette} package. Default is {stata colorpalette tableau:{it:tableau}}.{p_end}

{p2coldent : {opt fi(numlist max=3)}}The fill intensity of the layers in the other they are specified. The default values are {opt fi(50 75 100)}.{p_end}

{p2coldent : {opt addt:itles}}Add titles to upper layers. This adds the name and value in the top left corner of the boxes.{p_end}

{p2coldent : {opt titleprop}}Make the size of the box titles proportional to the area.{p_end}

{p2coldent : {opt labprop}}Make the size of the labels proportional to the area.{p_end}

{p2coldent : {opt labscale(num)}}This option changes how the labels are scaled. This is an advanced option and should be used cautiously. Default value is {opt labscale(0.5)}.
The scaling is sensitive to change in this value so modify in small increments.{p_end}

{p2coldent : {opt noval:ues}}Do not add the values in the inner-most boxes. If the graph is too crowded, this option might help.{p_end}

{p2coldent : {opt nolab:els}}Do not add anylabels. This gives just boxes without any numbers.{p_end}

{p2coldent : {opt labs:ize(string max=3)}}The size of the labels. The default values are {opt labs(2 2 2)}. If only one value is specified, it will passed on to all the layers.{p_end}

{p2coldent : {opt title, subtitle, note}}These are standard twoway graph options.{p_end}

{p2coldent : {opt scheme(str)}}Load the custom scheme. Above options can be used to fine tune individual elements.{p_end}

{synoptline}
{p2colreset}{...}


{title:Dependencies}

The {browse "http://repec.sowi.unibe.ch/stata/palettes/index.html":palette} package (Jann 2018, 2022) is required for {cmd:circlepack}:

{stata ssc install palettes, replace}
{stata ssc install colrspace, replace}

Even if you have these installed, it is highly recommended to check for updates: {stata ado update, update}

{title:Examples}

{ul:{it:Set up the data}}

use "https://github.com/asjadnaqvi/stata-circlepack/blob/main/data/demo_r_pjangrp3_clean.dta?raw=true", clear

drop year
keep NUTS_ID y_TOT

drop if y_TOT==0

keep if length(NUTS_ID)==5

gen NUTS2 = substr(NUTS_ID, 1, 4)
gen NUTS1 = substr(NUTS_ID, 1, 3)
gen NUTS0 = substr(NUTS_ID, 1, 2)

ren NUTS_ID NUTS3

- {stata circlepack y_TOT, by(NUTS0)}

- {stata circlepack y_TOT, by(NUTS0) addtitles labsize(2) format(%15.0fc)}

- {stata circlepack y_TOT if NUTS0=="AT", by(NUTS3 NUTS2) addtitles noval labsize(1.6) format(%15.0fc)}


{hline}

{title:Acknowledgements}

Fayssal Ayad found errors with duplicate and zero values that was causing the layers to be drawn improperly (v1.01).

{title:Package details}

Version      : {bf:circlepack} v1.2
This release : 15 Jan 2023
First release: 08 Sep 2022
Repository   : {browse "https://github.com/asjadnaqvi/circlepack":GitHub}
Keywords     : Stata, graph, circle packing, circlepack, A1.0
License      : {browse "https://opensource.org/licenses/MIT":MIT}

Author       : {browse "https://github.com/asjadnaqvi":Asjad Naqvi}
E-mail       : asjadnaqvi@gmail.com
Twitter      : {browse "https://twitter.com/AsjadNaqvi":@AsjadNaqvi}


{title:References}

{p 4 8 2}Huang, W., Li, Y., Li, C.M., Xu, R.C. (2006). {browse "https://www.sciencedirect.com/science/article/abs/pii/S0305054805000031":New heuristics for packing unequal circles into a circular container}. Computers & Operations Research 33(8).

{p 4 8 2}Bostock, M. {browse "https://observablehq.com/@d3/d3-packenclose":D3 packEnclose}. {browse "https://observablehq.com/":Observable HQ}.

{p 4 8 2}Jann, B. (2018). {browse "https://www.stata-journal.com/article.html?article=gr0075":Color palettes for Stata graphics}. The Stata Journal 18(4): 765-785.

{p 4 8 2}Jann, B. (2022). {browse "https://ideas.repec.org/p/bss/wpaper/43.html":Color palettes for Stata graphics: an update}. University of Bern Social Sciences Working Papers No. 43. 

{p 4 8 2}Lecomte, J. {browse "https://github.com/elmotec/circlify":Python circlify}.

{title:Other visualization packages}

{psee}
    {helpb arcplot}, {helpb alluvial}, {helpb bimap}, {helpb bumparea}, {helpb bumpline}, {helpb circlebar}, {helpb circlepack}, {helpb clipgeo}, {helpb delaunay}, {helpb joyplot}, 
	{helpb marimekko}, {helpb sankey}, {helpb schemepack}, {helpb spider}, {helpb streamplot}, {helpb sunburst}, {helpb treecluster}, {helpb treemap}



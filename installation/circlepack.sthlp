{smcl}
{* 07Jun2026}{...}
{hi:help circlepack}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-circlepack":circlepack v1.21 (GitHub)}}

{hline}

{title:circlepack}: is a Stata package for plotting hierarchical data as packed {browse "https://en.wikipedia.org/wiki/Circle_packing":circles}. 

{p 4 4 2}
This program implements the {it:A1.0} circle-packing algorithm based on the work by Huang et. al. (2006), and is inspired by D3's
{browse "https://observablehq.com/@d3/d3-packenclose":packEnclose} and Python's {browse "https://github.com/elmotec/circlify":circlify} routines.


{marker syntax}{title:Syntax}
{p 8 15 2}

{cmd:circlepack} {it:numvar} {ifin}, {cmd:by}({it:variables (min=1 max=3)}) 
    {cmd:[} {cmd:pad}({it:num}) {cmd:points}({it:num}) {cmd:angle}({it:num}) {cmd:circle0} {cmd:circle0c}({it:str}) {cmd:format}({it:str}) {cmd:palette}({it:str}) {cmd:share} 
      {cmd:labprop} {cmd:titleprop} {cmd:labscale}({it:num}) {cmdab:thresh:old}({it:num}) {cmd:fi}({it:list}) {cmdab:addt:itles} {cmdab:noval:ues} {cmdab:nolab:els} {cmdab:labs:ize}({it:num}) 
      {cmd:title}({it:str}) {cmd:subtitle}({it:str}) {cmd:note}({it:str}) {cmd:scheme}({it:str}) {cmd:name}({it:str}) {cmd:]}


{marker options}{title:Options}

{marker required}{dlgtab:Required}

{p2coldent : {opt circlepack} {it:numvar}}The command requires a {it:numeric variable} that contains the values.{p_end}

{p2coldent : {opt by(group vars)}}At least one {it:by()} string variable needs to be specified, and a maximum of three string variables are allowed. These also are used as labels.
The order is parent layer first followed by child layer or more aggregated layers should be specified first.{p_end}

{marker display}{dlgtab:Display options}

{p2coldent : {opt pad(num)}}Add padding to the circles. Default value is {it:0.1}. A value of 0 implies no padding.{p_end}

{p2coldent : {opt points(num)}}Number of points used to define each circle. Default value is {it:60}. A value of 3 gives triangles, 6 gives hexagons, 8 gives octagons, and so on.
Larger values produce smoother circles.{p_end}

{p2coldent : {opt angle(num)}}Rotation angle for the points on each circle. Default value is {it:0}. This can be used to rotate polygonal circle approximations.{p_end}

{p2coldent : {opt format(fmt)}}Format used for the value labels. The default option is {opt format(%12.0fc)} for values and {opt format(%5.2f)} if {opt share} is specified.{p_end}

{p2coldent : {opt share}}Show percentage shares of the total instead of the actual values for all the layers.{p_end}

{p2coldent : {opt thresh:old(num)}}The value below which categories are combined in a "Rest of ..." category. Default is {opt thresh(0)}.{p_end}

{marker colors}{dlgtab:Colors and palette}

{p2coldent : {opt palette(str)}}Named color scheme defined in the {stata help colorpalette:colorpalette} package. Default is {stata colorpalette tableau:{it:tableau}}.{p_end}

{p2coldent : {opt circle0}}Draw the bounding circle.{p_end}

{p2coldent : {opt circle0c(str)}}Define the bounding circle color.{p_end}

{p2coldent : {opt fi(numlist max=3)}}The fill intensity of the layers in the order they are specified. The default values are {opt fi(50 75 100)}.{p_end}

{marker labels}{dlgtab:Labels and text}

{p2coldent : {opt addt:itles}}Add titles to upper layers. This adds the name and value in the top left corner of the boxes.{p_end}

{p2coldent : {opt noval:ues}}Do not add the values in the inner-most boxes. If the graph is too crowded, this option might help.{p_end}

{p2coldent : {opt nolab:els}}Do not add any labels. This gives just circles without any numbers. This option overrides the above two options.{p_end}

{p2coldent : {opt labcond(value)}}The minimum value for showing the value labels. For example, {opt labcond(20)} will only plot values greater than 20.{p_end}

{p2coldent : {opt labs:ize(str list)}}The size of the labels. The default values are {opt labs(2 2 2)}. If only one value is specified, it will be passed on to all the layers.{p_end}

{p2coldent : {opt labprop}}Make the size of the labels proportional to the area.{p_end}

{p2coldent : {opt labscale(num)}}This option changes how the labels are scaled. This is an advanced option and should be used cautiously. Default value is {opt labscale(0.5)}.
The scaling is sensitive to changes in this value, so modify it in small increments.{p_end}

{p2coldent : {opt titleprop}}Make the size of the box titles proportional to the area.{p_end}

{marker titles}{dlgtab:Other options}

{p2coldent : {opt *}}All other standard twoway options not elsewhere specified and not blocked by the program.{p_end}

{synoptline}
{p2colreset}{...}


{title:Dependencies}

{stata ssc install palettes, replace}
{stata ssc install colrspace, replace}
{stata ssc install graphfunctions, replace}

Even if you have these installed, it is highly recommended to check for updates: {stata ado update, update}


{title:Examples}

{ul:{it:Set up the data}}

{stata use "https://github.com/asjadnaqvi/stata-circlepack/blob/main/data/demo_r_pjangrp3_clean.dta?raw=true", clear}

{stata drop year}
{stata keep NUTS_ID y_TOT}
{stata drop if y_TOT==0}
{stata keep if length(NUTS_ID)==5}
{stata gen NUTS2 = substr(NUTS_ID, 1, 4)}
{stata gen NUTS1 = substr(NUTS_ID, 1, 3)}
{stata gen NUTS0 = substr(NUTS_ID, 1, 2)}
{stata ren NUTS_ID NUTS3}

- {stata circlepack y_TOT, by(NUTS0)}

- {stata circlepack y_TOT, by(NUTS0) addtitles labsize(2) format(%15.0fc)}

- {stata circlepack y_TOT if NUTS0=="AT", by(NUTS3 NUTS2) addtitles noval labsize(1.6) format(%15.0fc)}


{hline}

{title:Feedback}

Please submit bugs, errors, or feature requests on {browse "https://github.com/asjadnaqvi/stata-circlepack/issues":GitHub} by opening a new issue.


{title:Package details}

Version      : {bf:circlepack} v1.21
This release : 07 Jun 2026
First release: 08 Sep 2022
Repository   : {browse "https://github.com/asjadnaqvi/circlepack":GitHub}
Keywords     : Stata, graph, circle packing, circlepack, A1.0
License      : {browse "https://opensource.org/licenses/MIT":MIT}

Author       : {browse "https://github.com/asjadnaqvi":Asjad Naqvi}
E-mail       : asjadnaqvi@gmail.com
Twitter      : {browse "https://twitter.com/AsjadNaqvi":@AsjadNaqvi}


{title:Citation guidelines}

See {browse "https://ideas.repec.org/c/boc/bocode/s459124.html"} for the official SSC citation.
Please note that the GitHub version might be newer than the SSC version.


{title:References}

{p 4 8 2}Huang, W., Li, Y., Li, C.M., Xu, R.C. (2006). {browse "https://www.sciencedirect.com/science/article/abs/pii/S0305054805000031":New heuristics for packing unequal circles into a circular container}. Computers & Operations Research 33(8).

{p 4 8 2}Bostock, M. (2022). {browse "https://observablehq.com/@d3/d3-packenclose":D3 packEnclose}. {browse "https://observablehq.com/":Observable HQ}.

{p 4 8 2}Jann, B. (2018). {browse "https://www.stata-journal.com/article.html?article=gr0075":Color palettes for Stata graphics}. The Stata Journal 18(4): 765-785.

{p 4 8 2}Jann, B. (2022). {browse "https://ideas.repec.org/p/bss/wpaper/43.html":Color palettes for Stata graphics: an update}. University of Bern Social Sciences Working Papers No. 43.

{p 4 8 2}Lecomte, J. (2022). {browse "https://github.com/elmotec/circlify":Python circlify}.


{title:Other visualization packages}

{psee}
    {helpb arcplot}, {helpb alluvial}, {helpb bimap}, {helpb bumparea}, {helpb bumpline}, {helpb circlebar}, {helpb circlepack}, {helpb clipgeo}, {helpb delaunay}, {helpb graphfunctions},
  {helpb geoboundary}, {helpb geoflow}, {helpb joyplot}, {helpb marimekko}, {helpb polarspike}, {helpb sankey}, {helpb schemepack}, {helpb spider}, {helpb splinefit}, {helpb streamplot},
  {helpb sunburst}, {helpb ternary}, {helpb tidytuesday}, {helpb treecluster}, {helpb treemap}, {helpb trimap}, {helpb waffle}, {helpb vcontrol}

Visit {browse "https://github.com/asjadnaqvi":GitHub} for further details.


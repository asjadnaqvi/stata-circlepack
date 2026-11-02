{smcl}
{* 02Nov2026}{...}
{hi:help circlepack}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-circlepack":circlepack v1.3 (GitHub)}}

{hline}

{title:circlepack}: is a Stata package for plotting hierarchical data as packed {browse "https://en.wikipedia.org/wiki/Circle_packing":circles}. 

{p 4 4 2}
This program implements the {it:A1.0} circle-packing algorithm based on the work by Huang et. al. (2006), and is inspired by D3's
{browse "https://observablehq.com/@d3/d3-packenclose":packEnclose} and Python's {browse "https://github.com/elmotec/circlify":circlify} routines.


{marker syntax}{title:Syntax}
{p 8 15 2}

{cmd:circlepack} {it:numvar} {ifin}, {cmd:by}({it:variables (min=1)})
    {cmd:[} {cmd:pad}({it:num}) {cmd:points}({it:num}) {cmd:angle}({it:num}) {cmd:circle0} {cmd:circle0c}({it:str}) {cmd:format}({it:str}) {cmd:palette}({it:str}) {cmd:share} 
      {cmd:labprop} {cmd:titleprop} {cmd:labscale}({it:num}) {cmdab:thresh:old}({it:num}) {cmd:fi}({it:list}) {cmdab:not:itles} {cmdab:noval:ues} {cmdab:nolab:els} {cmdab:labs:ize}({it:list})
      {cmd:labcolor}({it:str}) {cmd:labcond}({it:num})
      {cmd:title}({it:str}) {cmd:subtitle}({it:str}) {cmd:note}({it:str}) {cmd:scheme}({it:str}) {cmd:name}({it:str}) {cmd:]}


{marker options}{title:Options}

{marker required}{dlgtab:Required}

{p2coldent : {opt circlepack} {it:numvar}}The command requires a {it:numeric variable} that contains the values.{p_end}

{p2coldent : {opt by(group vars)}}One or more grouping variables, ordered from parent to child. There is no package-imposed maximum depth.
String values are used as labels; numeric variables use their numeric codes. Categories are identified by their complete parent path, so child names may repeat under different parents.
Observations with missing values in any grouping variable are excluded, as are nonpositive or missing values of {it:numvar}.{p_end}

{marker display}{dlgtab:Display options}

{p2coldent : {opt pad(num)}}Reduce each parent's available radius by this nonnegative amount before packing its children. Default is {it:0.1}; 0 implies no padding.
Padding is absolute, not proportional. Effective padding is {cmd:min(pad, parent_radius/2)}, so small circles retain at least half their radius for children.{p_end}

{p2coldent : {opt points(num)}}Number of points used to define each circle. Default value is {it:60}. A value of 3 gives triangles, 6 gives hexagons, 8 gives octagons, and so on.
Larger values produce smoother circles. The value must be an integer of at least 3.{p_end}

{p2coldent : {opt angle(num)}}Rotation angle for the points on each circle. Default value is {it:0}. This can be used to rotate polygonal circle approximations.{p_end}

{p2coldent : {opt format(fmt)}}Format used for the value labels. The default option is {opt format(%12.0fc)} for values and {opt format(%5.2f)} if {opt share} is specified.{p_end}

{p2coldent : {opt share}}Show percentage shares of the total instead of the actual values for all the layers.{p_end}

{p2coldent : {opt thresh:old(num)}}Leaf categories with aggregated values at or below this threshold are combined in a "Rest of ..." category within each complete parent path.
Duplicate complete paths are summed before applying the threshold. Default is {opt thresh(0)}.{p_end}

{marker colors}{dlgtab:Colors and palette}

{p2coldent : {opt palette(str)}}Named color scheme defined in the {stata help colorpalette:colorpalette} package. Default is {stata colorpalette tableau:{it:tableau}}.{p_end}

{p2coldent : {opt circle0}}Draw the bounding circle.{p_end}

{p2coldent : {opt circle0c(str)}}Define the bounding circle color.{p_end}

{p2coldent : {opt fi(numlist)}}Fill intensities from 0 to 100, ordered from parent to child. Shorter lists repeat their final entry.
Defaults are 100 for one layer, {opt fi(60 90)} for two, and {opt fi(50 75 100)} for three. At greater depths, defaults increase evenly from 50 to 100.{p_end}

{marker labels}{dlgtab:Labels and text}

{p2coldent : {opt not:itles}}Suppress parent-layer titles, which are shown by default above each parent circle. Leaf labels remain centered inside the deepest circles.
This option does not suppress the overall graph {opt title()}.{p_end}

{p2coldent : {opt noval:ues}}Do not add values in the deepest circles. Parent titles retain their values. If the graph is too crowded, this option might help.{p_end}

{p2coldent : {opt nolab:els}}Do not add any labels. This gives just circles without any numbers. This option overrides the above two options.{p_end}

{p2coldent : {opt labcond(value)}}The minimum aggregated value for showing labels, values, and titles. For example, {opt labcond(20)} shows labels for values of at least 20.
This condition uses values, including when {opt share} is specified.{p_end}

{p2coldent : {opt labs:ize(str list)}}Label sizes ordered from parent to child. The default is 2 at every layer.
Shorter lists repeat their final entry. Use numeric sizes with {opt labprop} or {opt titleprop}.{p_end}

{p2coldent : {opt labcolor(str)}}Color of labels, values, and parent titles. Default is black.{p_end}

{p2coldent : {opt labprop}}Make the size of the labels proportional to the area.{p_end}

{p2coldent : {opt labscale(num)}}This option changes how the labels are scaled. This is an advanced option and should be used cautiously. Default value is {opt labscale(0.5)}.
The scaling is sensitive to changes in this value, so modify it in small increments.{p_end}

{p2coldent : {opt titleprop}}Make the size of parent titles proportional to the area's share of the total.{p_end}

{marker titles}{dlgtab:Other options}

{p2coldent : {opt *}}All other standard twoway options not elsewhere specified and not blocked by the program.{p_end}

{synoptline}
{p2colreset}{...}


{title:Dependencies}

{stata ssc install palettes, replace}
{stata ssc install colrspace, replace}
{stata ssc install moremata, replace}

{title:Examples}

See GitHub for details.


{hline}

{title:Feedback}

Please submit bugs, errors, or feature requests on {browse "https://github.com/asjadnaqvi/stata-circlepack/issues":GitHub} by opening a new issue.


{title:Package details}

Version      : {bf:circlepack} v1.3
This release : 02 Nov 2026
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

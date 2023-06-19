![StataMin](https://img.shields.io/badge/stata-2015-blue) ![issues](https://img.shields.io/github/issues/asjadnaqvi/stata-circlepack) ![license](https://img.shields.io/github/license/asjadnaqvi/stata-circlepack) ![Stars](https://img.shields.io/github/stars/asjadnaqvi/stata-circlepack) ![version](https://img.shields.io/github/v/release/asjadnaqvi/stata-circlepack) ![release](https://img.shields.io/github/release-date/asjadnaqvi/stata-circlepack)


# circlepack v1.1
(16 May 2023)

A Stata package for circle packing. It is based on D3's [packEnclose](https://observablehq.com/@d3/d3-packenclose) and Python's [circlify](https://github.com/elmotec/circlify) algorithms.


## Installation

The package can be installed via SSC or GitHub. The GitHub version, *might* be more recent due to bug fixes, feature updates etc, and *may* contain syntax improvements and changes in *default* values. See version numbers below. Eventually the GitHub version is published on SSC.

The SSC version (**v1.1**):
```
ssc install circlepack, replace
```

Or it can be installed from GitHub (**v1.1**):

```
net install circlepack, from("https://raw.githubusercontent.com/asjadnaqvi/stata-circlepack/main/installation/") replace
```


The `palettes` package is required to run this command:

```
ssc install palettes, replace
ssc install colrspace, replace
```

Even if you have the package installed, make sure that it is updated `ado update, update`.

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

The syntax for v1.1 is as follows:

```
circlepack numvar [if] [in], by(variables (min=1, max=3)) 
        [ pad(num) points(num) angle(num) circle0 circle0c(str) format(str) palette(string) share 
          labprop titleprop labscale(num) threshold(num) fi(list) addtitles novalues nolabels labsize(num) 
          title(str) subtitle(str) note(str) scheme(str) name(str) ]

```

See the help file `help circlepack` for details.

The most basic use is as follows:

```
circlepack numvar, over(variable(s))
```


where `numvar` is a numeric variable, and `over()` are upto three variables, defined from more aggregate to finer levels.



## Examples

Set up the data:

```
clear
set scheme white_tableau
graph set window fontface "Arial Narrow"

use "https://github.com/asjadnaqvi/stata-circlepack/blob/main/data/demo_r_pjangrp3_clean.dta?raw=true", clear
```



```
circlepack pop, by(NUTS0) format(%15.0fc) title("Population of European countries")
```

<img src="/figures/circlepack1.png" height="600">


```
circlepack pop, by(NUTS0) title("Population of European countries") noval
```

<img src="/figures/circlepack2.png" height="600">


```
circlepack pop, by(NUTS0) title("Population of European countries") circle0 noval
```

<img src="/figures/circlepack3.png" height="600">


```
circlepack pop, by(NUTS0 NUTS1) format(%15.0fc) noval circle0 
```

<img src="/figures/circlepack4.png" height="600">


```
circlepack pop, by(NUTS0 NUTS1) format(%15.0fc) noval addtitles
```

<img src="/figures/circlepack5.png" height="600">

```
circlepack pop, by(NUTS0 NUTS1 NUTS2) format(%15.0fc) nolab pad(0.06)
```

<img src="/figures/circlepack6.png" height="600">

```
circlepack pop if NUTS0=="AT", by(NUTS1 NUTS2 NUTS3) ///
	addtitles noval format(%15.0fc) circle0 ///
	title("Population of Austria at NUTS2 and NUTS3 level") 
```

<img src="/figures/circlepack7.png" height="600">

```
circlepack pop if NUTS0=="NL", by(NUTS2 NUTS3) addtitles ///
	format(%15.0fc) title("Population of Netherlands at NUTS2 and NUTS3 level") 
```

<img src="/figures/circlepack8.png" height="600">


```
circlepack pop if NUTS0=="NL", by(NUTS1 NUTS2 NUTS3) ///
	addtitles noval format(%15.0fc) title("Population of Netherlands at NUTS1-NUTS3 level") ///
	palette(CET L10) 
```

<img src="/figures/circlepack9.png" height="600">

```
circlepack pop if NUTS0=="NL", by(NUTS1 NUTS2 NUTS3)  ///
	addtitles noval format(%15.0fc) title("Population of Netherlands at NUTS1-NUTS3 level") ///
	palette(CET L10) points(6) pad(0.3)
```

<img src="/figures/circlepack10.png" height="600">

```
circlepack pop if NUTS0=="PT", by(NUTS2 NUTS3) ///
	addtitles noval format(%15.0fc) title("Population of Portugal at NUTS1-NUTS3 level") ///
	palette(CET C6) points(12) pad(0.1) 
```

<img src="/figures/circlepack11.png" height="600">


### v1.1 updates

```
circlepack    pop if NUTS0=="ES", by(NUTS1 NUTS3) addtitle
```

<img src="/figures/circlepack12.png" height="600">

```
circlepack    pop if NUTS0=="ES", by(NUTS1 NUTS3) addtitle labprop titleprop
```

<img src="/figures/circlepack13.png" height="600">

```
circlepack    pop if NUTS0=="ES", by(NUTS1 NUTS3) addtitle labprop titleprop labs(1.5 2.5)
```

<img src="/figures/circlepack14.png" height="600">

```
circlepack    pop if NUTS0=="ES", by(NUTS1 NUTS3) addtitle labprop titleprop threshold(1000000)
```

<img src="/figures/circlepack15.png" height="600">

```
circlepack    pop if NUTS0=="ES", by(NUTS1 NUTS3) addtitle labprop titleprop labcond(1000000)
```

<img src="/figures/circlepack16.png" height="600">

```
circlepack    pop if NUTS0=="ES", by(NUTS1 NUTS2 NUTS3) addtitle labprop titleprop labcond(1000000)
```

<img src="/figures/circlepack17.png" height="600">

```
circlepack    pop if NUTS0=="ES", by(NUTS1 NUTS2 NUTS3)  nolab fi(10 40 80)
```

<img src="/figures/circlepack18.png" height="600">

```
circlepack    pop if NUTS0=="ES", by(NUTS1 NUTS2 NUTS3)  nolab fi(40 60 100)
```

<img src="/figures/circlepack19.png" height="600">


```
circlepack    pop if NUTS0=="ES", by(NUTS1 NUTS3) addtitle labprop titleprop threshold(1000000) share
```

<img src="/figures/circlepack20.png" height="600">

## Feedback

Please open an [issue](https://github.com/asjadnaqvi/stata-circlepack/issues) to report errors, feature enhancements, and/or other requests. 


## Versions

**v1.0 (16 May 2023)**
- Major update with several new options added to align it with the `treemap` package.
- `labprop`, `titleprop`, `labscale()`, `threshold()`, `fi()`, `share` options added.
- Minor fixes to the code.

**v1.01 (24 Nov 2022)**
- Sorting stabilized to prevent random circlemap layouts.
- Negative and zero values are automatically dropped.
- Improved precision of variables.
- Minor fixes in the code.

**v1.0 (08 Sep 2022)**
- First release






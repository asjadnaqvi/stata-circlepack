
![StataMin](https://img.shields.io/badge/stata-2015-blue) ![issues](https://img.shields.io/github/issues/asjadnaqvi/stata-circlepack) ![license](https://img.shields.io/github/license/asjadnaqvi/stata-circlepack) ![Stars](https://img.shields.io/github/stars/asjadnaqvi/stata-circlepack) ![version](https://img.shields.io/github/v/release/asjadnaqvi/stata-circlepack) ![release](https://img.shields.io/github/release-date/asjadnaqvi/stata-circlepack)

[Installation](#Installation) | [Syntax](#Syntax)  | [Citation](#Citation-guidelines) | [Examples](#Examples) | [Feedback](#Feedback) | [Change log](#Change-log)

---

![circlepack-1](https://github.com/asjadnaqvi/stata-circlepack/assets/38498046/1d215337-0bf6-4b8f-9d00-f338267e631c)


# circlepack v1.3
(02 Nov 2026)

A Stata package for circle packing. It is based on D3's [packEnclose](https://observablehq.com/@d3/d3-packenclose) and Python's [circlify](https://github.com/elmotec/circlify) algorithms.


## Installation

The package can be installed via SSC or GitHub. The GitHub version, *might* be more recent due to bug fixes, feature updates etc, and *may* contain syntax improvements and changes in *default* values. See version numbers below. Eventually the GitHub version is published on SSC.

The SSC version (**v1.2**):
```
ssc install circlepack, replace
```

Or it can be installed from GitHub (**v1.3**, once published):

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

## Citation guidelines

See [SSC citation](https://ideas.repec.org/c/boc/bocode/s459120.html)


## Syntax

The syntax for the latest version is as follows:

```stata
circlepack numvar [if] [in], by(variables (min=1))
        [ pad(num) points(num) angle(num) circle0 circle0c(str) format(str) palette(string) share 
          labprop titleprop labscale(num) threshold(num) fi(list) notitles novalues nolabels labsize(list)
          labcolor(str) labcond(num) title(str) subtitle(str) note(str) scheme(str) name(str) ]
```

See the help file `help circlepack` for details.

The most basic use is as follows:

```stata
circlepack numvar, by(variable(s))
```

where `numvar` is a numeric variable, and `by()` contains one or more grouping variables, ordered from parent to child. 


## Examples

Set up the data:

```stata
clear
set scheme white_tableau
graph set window fontface "Arial Narrow"

use "https://github.com/asjadnaqvi/stata-circlepack/blob/main/data/demo_r_pjangrp3_clean.dta?raw=true", clear
```



```stata
circlepack pop, by(NUTS0) format(%15.0fc) title("Population of European countries")
```

<img src="/figures/circlepack1.png" width="100%">


```stata
circlepack pop, by(NUTS0) title("Population of European countries") noval
```

<img src="/figures/circlepack2.png" width="100%">


```stata
circlepack pop, by(NUTS0) title("Population of European countries") circle0 noval
```

<img src="/figures/circlepack3.png" width="100%">


```stata
circlepack pop, by(NUTS0 NUTS1) format(%15.0fc) noval circle0 notitles
```

<img src="/figures/circlepack4.png" width="100%">


```stata
circlepack pop, by(NUTS0 NUTS1) format(%15.0fc) noval
```

<img src="/figures/circlepack5.png" width="100%">

```stata
circlepack pop, by(NUTS0 NUTS1 NUTS2) format(%15.0fc) nolab pad(0.06)
```

<img src="/figures/circlepack6.png" width="100%">

```stata
circlepack pop if NUTS0=="AT", by(NUTS1 NUTS2 NUTS3) ///
	noval format(%15.0fc) ///
	title("Population of Austria at NUTS2 and NUTS3 level") circle0
```

<img src="/figures/circlepack7.png" width="100%">

```stata
circlepack pop if NUTS0=="NL", by(NUTS2 NUTS3) ///
	format(%15.0fc) title("Population of Netherlands at NUTS2 and NUTS3 level") 
```

<img src="/figures/circlepack8.png" width="100%">


```stata
circlepack pop if NUTS0=="NL", by(NUTS1 NUTS2 NUTS3) ///
	noval format(%15.0fc) title("Population of Netherlands at NUTS1-NUTS3 level") ///
	palette(CET L10) 
```

<img src="/figures/circlepack9.png" width="100%">

```stata
circlepack pop if NUTS0=="NL", by(NUTS1 NUTS2 NUTS3)  ///
	noval format(%15.0fc) title("Population of Netherlands at NUTS1-NUTS3 level") ///
	palette(CET L10) points(6) pad(0.3)
```

<img src="/figures/circlepack10.png" width="100%">

```stata
circlepack pop if NUTS0=="PT", by(NUTS2 NUTS3) ///
	noval format(%15.0fc) title("Population of Portugal at NUTS1-NUTS3 level") ///
	palette(CET C6) points(12) pad(0.1) 
```

<img src="/figures/circlepack11.png" width="100%">


### v1.1 updates

```stata
circlepack    pop if NUTS0=="ES", by(NUTS1 NUTS3)
```

<img src="/figures/circlepack12.png" width="100%">

```stata
circlepack    pop if NUTS0=="ES", by(NUTS1 NUTS3) labprop titleprop
```

<img src="/figures/circlepack13.png" width="100%">

```stata
circlepack    pop if NUTS0=="ES", by(NUTS1 NUTS3) labprop titleprop labs(1.5 2.5)
```

<img src="/figures/circlepack14.png" width="100%">

```stata
circlepack    pop if NUTS0=="ES", by(NUTS1 NUTS3) labprop titleprop threshold(1000000)
```

<img src="/figures/circlepack15.png" width="100%">

```stata
circlepack    pop if NUTS0=="ES", by(NUTS1 NUTS3) labprop titleprop labcond(1000000)
```

<img src="/figures/circlepack16.png" width="100%">

```stata
circlepack    pop if NUTS0=="ES", by(NUTS1 NUTS2 NUTS3) labprop titleprop labcond(1000000)
```

<img src="/figures/circlepack17.png" width="100%">

```stata
circlepack    pop if NUTS0=="ES", by(NUTS1 NUTS2 NUTS3)  nolab fi(10 40 80)
```

<img src="/figures/circlepack18.png" width="100%">

```stata
circlepack    pop if NUTS0=="ES", by(NUTS1 NUTS2 NUTS3)  nolab fi(40 60 100)
```

<img src="/figures/circlepack19.png" width="100%">


```stata
circlepack    pop if NUTS0=="ES", by(NUTS1 NUTS3) labprop titleprop threshold(1000000) share
```

<img src="/figures/circlepack20.png" width="100%">

### Six hierarchy levels

The same synthetic sales data used in the treemap example illustrate six layers, including child names repeated under different parents.

```stata
clear
input str8 division str8 region str8 country str8 city str8 store str8 product double sales
"Consumer" "Europe" "Austria" "Vienna" "Central" "Hardware" 120
"Consumer" "Europe" "Austria" "Vienna" "Central" "Software" 80
"Consumer" "Europe" "Austria" "Graz"   "Central" "Hardware" 100
"Consumer" "Europe" "Germany" "Berlin" "Central" "Software" 140
"Consumer" "Asia"   "Japan"   "Tokyo"  "Central" "Hardware" 160
"Business" "Europe" "Austria" "Vienna" "Central" "Hardware" 130
"Business" "Europe" "Germany" "Berlin" "Central" "Software" 170
"Business" "Asia"   "Japan"   "Tokyo"  "Central" "Hardware" 110
"Business" "Asia"   "Japan"   "Osaka"  "Central" "Software" 90
end

// Short option lists repeat their last value at deeper levels.
circlepack sales, by(division region country city store product) ///
	pad(0.06) novalues labsize(1.8 1.4 1.1) ///
	labprop titleprop fi(35 50 65 75 85 100) format(%9.0fc) ///
	title("Sales across six hierarchy levels")
```

<img src="/figures/circlepack21_depth6.png" width="100%">

## Feedback

Please open an [issue](https://github.com/asjadnaqvi/stata-circlepack/issues) to report errors, feature enhancements, and/or other requests. 


## Change log

**v1.3 (02 Nov 2026)**
- Replaced the fixed three-layer pipeline with one arbitrary-depth hierarchy engine, retaining the existing packing heuristic.
- Extended `fi()` and `labsize()` lists to all layers, repeating the last supplied entry when needed.
- Fixed grouping and totals for child names repeated under different parents; stabilized tied values by category name.
- Preserved double precision in aggregation and coordinates, regardless of `set type`.
- Applied `threshold()` consistently to aggregated leaf categories within their complete parent path.
- Excluded observations with incomplete `by()` paths and added explicit checks for empty input.
- Capped padding at half each parent's radius to keep small circles drawable.
- Made `nolabels` suppress parent titles as well as leaf labels.
- Replaced `addtitles` with `notitles`: parent titles are now shown by default, matching `treemap`. Remove `addtitles` from existing calls, or use `notitles` to suppress parent titles.
- Removed the `carryforward` dependency.

**v1.21 (07 Jun 2026)**
- Fixed the Mata helper lookup so circlepack no longer fails with _circlify_level() not found.
- Several code optimizations.

**v1.2 (15 Jan 2024)**
- Minor cleanups, updated dependencies, and bug fixes.

**v1.1 (16 May 2023)**
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


*! circlepack v1.3 (02 Nov 2026)
*! Asjad Naqvi (asjadnaqvi@gmail.com)

*v1.3  (02 Nov 2026): One arbitrary-depth hierarchy engine. Parent-specific grouping, double precision, and per-layer styles.
*v1.21 (07 Jun 2026): minor bug fixes to better handle missing values and zeroes. Updated dependencies.
*v1.2  (15 Jan 2024): minor cleanups, updated dependencies, bug fixes.  
*v1.1  (16 May 2023): Major update. Several features added to make it more compatible with treemap.
*v1.01 (24 Nov 2022): Minor fixes to prevent duplicate value errors. Checks for 0s and negatives. Improved precision.
*v1.0  (08 Sep 2022): First release.


capture program drop circlepack
program define circlepack, sortpreserve rclass
	version 15
	syntax varlist(numeric max=1) [if] [in], by(varlist min=1) ///
		[ pad(real 0.1) angle(real 0) points(real 60) circle0 circle0c(string) ///
		  format(str) palette(string) NOTitles NOVALues NOLABels cond(string) ///
		  LABColor(string) share THRESHold(numlist max=1 >=0) labprop ///
		  labscale(real 0.5) LABSize(string) titleprop fi(numlist >=0 <=100) ///
		  labcond(real 0) * ]

	if missing(`pad') | `pad' < 0 {
		display as error "pad() must be nonnegative."
		exit 198
	}
	if missing(`points') | `points' < 3 | `points' != floor(`points') {
		display as error "points() must be an integer of at least 3."
		exit 198
	}
	if missing(`angle', `labscale', `labcond') {
		display as error "angle(), labscale(), and labcond() must be nonmissing."
		exit 198
	}
	capture findfile colorpalette.ado
	if _rc != 0 {
		display as error "The {bf:palettes} package is missing. Install the {stata ssc install palettes, replace:palettes} and {stata ssc install colrspace, replace:colrspace} packages."
		exit 198
	}
	local depth : word count `by'
	local firstby : word 1 of `by'
	local radius 10
	if "`threshold'" == "" local threshold 0
	if "`labsize'" == "" local labsize 2
	if "`labcolor'" == "" local labcolor black
	if "`circle0c'" == "" local circle0c gs15
	if "`format'" == "" {
		local format %12.0fc
		if "`share'" != "" local format %5.2f
	}
	local ficount : word count `fi'
	local sizecount : word count `labsize'
	forvalues d = 1/`depth' {
		local ix = min(`d', `sizecount')
		local size`d' : word `ix' of `labsize'
		local fi`d' 100
		if `depth' == 2 local fi`d' = cond(`d' == 1, 60, 90)
		if `depth' >= 3 local fi`d' = 50 + 50 * (`d' - 1) / (`depth' - 1)
		if `ficount' > 0 {
			local ix = min(`d', `ficount')
			local fi`d' : word `ix' of `fi'
		}
	}

	marksample touse, strok
	preserve
	quietly {
		keep if `touse'
		summarize `varlist', meanonly
		if r(min) <= 0 noisily display as text "`varlist' contains zeros or negative values. These have been dropped."
		drop if `varlist' <= 0 | missing(`varlist')
		tempvar inputvalue
		generate double `inputvalue' = `varlist'
		local groups
		foreach v of local by {
			tempvar group
			capture confirm string variable `v'
			if !_rc generate `group' = `v'
			else {
				generate `group' = strtrim(string(`v', "%24.17g"))
				drop if missing(`v')
			}
			drop if `group' == ""
			local groups `groups' `group'
		}
		count
		if r(N) == 0 {
			noisily display as error "no positive, nonmissing observations with complete by() values"
			exit 2000
		}
		keep `inputvalue' `groups'
		rename `inputvalue' __cp_input
		local by
		forvalues d = 1/`depth' {
			local v : word `d' of `groups'
			rename `v' __cp_group`d'
			local by `by' __cp_group`d'
		}
		collapse (sum) __cp_input, by(`by')
		if `threshold' > 0 {
			if `depth' == 1 {
				replace __cp_group1 = "Rest of `firstby'" if __cp_input <= `threshold'
			}
			else {
				local prev = `depth' - 1
				replace __cp_group`depth' = "Rest of " + __cp_group`prev' if __cp_input <= `threshold'
			}
			collapse (sum) __cp_input, by(`by')
		}
		local prefix
		forvalues d = 1/`depth' {
			local prefix `prefix' __cp_group`d'
			egen long __cp_id`d' = group(`prefix')
			if `d' == 1 generate long __cp_parent`d' = 0
			else {
				local prev = `d' - 1
				generate long __cp_parent`d' = __cp_id`prev'
			}
			bysort `prefix': egen double __cp_value`d' = total(__cp_input)
			egen byte __cp_tag`d' = tag(`prefix')
			gsort __cp_parent`d' -__cp_value`d' __cp_group`d'
			by __cp_parent`d': generate long __cp_order`d' = sum(__cp_tag`d')
		}

		tempfile cp_nodes
		tempname cp_post
		postfile `cp_post' long __depth __id __parent double __value ///
			long __order str2045 __cp_name using `cp_nodes', replace
		forvalues d = 1/`depth' {
			forvalues obs = 1/`=_N' {
				if __cp_tag`d'[`obs'] {
					post `cp_post' (`d') (__cp_id`d'[`obs']) (__cp_parent`d'[`obs']) ///
						(__cp_value`d'[`obs']) (__cp_order`d'[`obs']) (__cp_group`d'[`obs'])
				}
			}
		}
		postclose `cp_post'
		use `cp_nodes', clear
		foreach v in x y depth node parent value share cx cy r ty root order {
			generate double __cp_`v' = .
		}
		local nnode = _N
		mata: circlepack_layout_any(`radius', `pad', `angle', `points')
		drop in 1/`nnode'
		drop __depth __id __parent __value __order

		generate str2045 __cp_lab = __cp_name if __cp_value >= `labcond'
		local labelvalue __cp_value
		local suffix
		if "`share'" != "" {
			local labelvalue (__cp_share * 100)
			local suffix %
		}
		generate str80 __cp_num = string(`labelvalue', "`format'") + "`suffix'" if __cp_value >= `labcond'
		generate str2045 __cp_title = "{it:" + __cp_lab + " (" + __cp_num + ")}" if __cp_value >= `labcond'
		generate long __cp_row = _n

		if "`palette'" == "" local palette tableau
		local poptions
		if strpos("`palette'", ",") {
			tokenize "`palette'", p(",")
			local palette `1'
			local poptions `3'
		}
		levelsof __cp_order if __cp_depth == 1, local(roots)
		local nroot : word count `roots'
		colorpalette `palette', n(`nroot') `poptions' nograph
		forvalues i = 1/`nroot' {
			local color`i' `"`r(p`i')'"'
		}
		local plots
		local labels
		local titles
		forvalues d = 1/`depth' {
			levelsof __cp_node if __cp_depth == `d', local(ids)
			foreach node of local ids {
				summarize __cp_row if __cp_depth == `d' & __cp_node == `node', meanonly
				local row = r(min)
				local root = __cp_root[`row']
				local clr `"`color`root''"'
				local plots `"`plots' (area __cp_y __cp_x if __cp_depth == `d' & __cp_node == `node', nodropbase fi(`fi`d'') fc("`clr'") lc(black) lw(0.03))"'
				if "`nolabels'" == "" {
					local size `size`d''
					if (`d' == `depth' & "`labprop'" != "") | (`d' < `depth' & "`titleprop'" != "") {
						local size = max(2 * `size`d'' * __cp_share[`row']^`labscale', 0)
					}
					if `d' == `depth' {
						local labels `"`labels' (scatter __cp_cy __cp_cx in `row', mc(none) mlab(__cp_lab) mlabpos(0) mlabsize(`size') mlabc(`labcolor'))"'
						if "`novalues'" == "" {
							local labels `"`labels' (scatter __cp_cy __cp_cx in `row', mc(none) mlab(__cp_num) mlabpos(6) mlabgap(0) mlabsize(`size') mlabc(`labcolor'))"'
						}
					}
					else if "`notitles'" == "" {
						local gap = cond(`d' == 1, 0.8, 0)
						local titles `"`titles' (scatter __cp_ty __cp_cx in `row', mc(none) mlab(__cp_title) mlabpos(12) mlabgap(`gap') mlabsize(`size') mlabc(`labcolor'))"'
					}
				}
			}
		}
		local bounding
		if "`circle0'" != "" {
			local r0 = `radius' + `pad'
			local bounding (function sqrt(`r0'^2 - x^2), recast(area) fi(100) fc(`circle0c') lw(none) range(-`r0' `r0')) ///
				(function -sqrt(`r0'^2 - x^2), recast(area) fi(100) fc(`circle0c') lw(none) range(-`r0' `r0'))
		}
		noisily twoway `bounding' `plots' `labels' `titles', ///
			legend(off) xscale(off) yscale(off) aspect(1) xsize(1) ysize(1) ///
			xlabel(-`radius' `radius', nogrid) ylabel(-`radius' `radius', nogrid) `options'
		restore
	}
	return scalar depth = `depth'

end


***************************
*** Mata sub-routines   ***
***************************

capture mata mata drop circlepack_layout_any()
mata:
void circlepack_layout_any(real scalar radius, real scalar pad,
	real scalar angle, real scalar points)
{
	real matrix nodes, panel, bounds, packed, target, out, coords
	real colvector indices, roots, seq
	real scalar n, first, last, d, row, j, parentrow, total, off, count
	string colvector names, outnames

	nodes = st_data(., ("__depth", "__id", "__parent", "__value", "__order"))
	names = st_sdata(., "__cp_name")
	indices = order(nodes, (1, 3, 5))
	nodes = nodes[indices, .]
	names = names[indices]
	n = rows(nodes)
	bounds = J(n, 3, .)
	roots = J(n, 1, .)
	// IDs represent complete paths and are contiguous within each depth.
	panel = J(max(nodes[,1]), max(nodes[,2]), .)
	for (row = 1; row <= n; row++) panel[nodes[row,1], nodes[row,2]] = row
	total = sum(select(nodes[,4], nodes[,1] :== 1))
	if (total >= . | total <= 0) {
		errprintf("circlepack totals must be positive and finite\n")
		_error(198)
	}
	count = points + 1
	out = J(count*n, 13, .)
	outnames = J(count*n, 1, "")
	first = 1
	while (first <= n) {
		d = nodes[first,1]
		last = first
		while (last < n) {
			if (nodes[last+1,1] != d | nodes[last+1,3] != nodes[first,3]) break
			last++
		}
		if (d == 1) target = (0, 0, radius)
		else {
			parentrow = panel[d-1, nodes[first,3]]
			target = bounds[parentrow,.]
			target[3] = target[3] - min((pad, target[3]/2))
			if (target[3] >= . | target[3] <= 0) {
				errprintf("nonpositive or missing parent radius at hierarchy level %g\n", d)
				_error(198)
			}
		}
		packed = circlify_level(nodes[|first,4 \ last,4|], target)
		if (any(packed :>= .) | any(packed[,3] :<= 0)) {
			errprintf("invalid circle geometry at hierarchy level %g\n", d)
			_error(198)
		}
		bounds[|first,1 \ last,3|] = packed
		for (row = first; row <= last; row++) {
			j = row - first + 1
			if (d == 1) roots[row] = nodes[row,5]
			else roots[row] = roots[parentrow]
			off = count*(row-1)
			coords = returnbounds(packed[j,.], angle, points)
			out[|off+1,1 \ off+count,2|] = coords \ coords[1,.]
			out[|off+1,3 \ off+count,7|] = J(count,1,1) *
				(d, nodes[row,2], nodes[row,3], nodes[row,4], nodes[row,4]/total)
			out[off+1,8..9] = packed[j,1..2]
			out[|off+1,10 \ off+count,10|] = J(count,1,packed[j,3])
			out[off+1,11] = max(coords[,2])
			out[|off+1,12 \ off+count,13|] = J(count,1,1) * (roots[row], nodes[row,5])
			outnames[|off+1 \ off+count|] = J(count,1,names[row])
		}
		first = last + 1
	}
	st_addobs(count*n)
	seq = (n+1)::((count+1)*n)
	st_store(seq, ("__cp_x", "__cp_y", "__cp_depth", "__cp_node", "__cp_parent",
		"__cp_value", "__cp_share", "__cp_cx", "__cp_cy", "__cp_r", "__cp_ty",
		"__cp_root", "__cp_order"), out)
	st_sstore(seq, "__cp_name", outnames)
}
end



****************************
// 	  circlify_level     //  
****************************

cap mata mata drop circlify_level()
cap mata mata drop _circlify_level()

mata
	function circlify_level(data, target_enclosure)   // 
	{
		all_circles = J(rows(data), 3, .)
		packed  = pack_A1_0(data)
		enclosure = enclose(packed)
		scaled = scale(packed, target_enclosure, enclosure)    
		return (scaled)

	}

	function _circlify_level(data, target_enclosure)   // 
	{
		return(circlify_level(data, target_enclosure))
	}
end




**********************
// 	  pack_A1_0     //  
**********************

cap mata mata drop pack_A1_0()

mata // pack_A1_0
	function pack_A1_0(data)   // 
	{		
		placed_circles = J(1,3,.)
	
		radii = sqrt(data)
		
		for (i=1; i<= rows(radii); i++) {	
		
			here = radii[i]
			next = (i == rows(radii) ? . : radii[i + 1])
			
			placed_circles = place_new_A1_0(here, next, placed_circles, get_hole_degree_radius_w)
		}
		
		return (placed_circles)
	
	}
end	
	



***************************
// 	  place_new_A1_0     //  
***************************

cap mata mata drop place_new_A1_0()

mata // place_new_A1_0
	function place_new_A1_0(radius, next, const_placed_circles, get_hole_degree)   // 
	{		

		placed_circles = const_placed_circles
		
		n_circles = rows(placed_circles)
		
		
		if (n_circles <= 1) { 
			
			x = (placed_circles[1,1] == . ? radius : -1 * radius) 

			if (placed_circles[1,1] == .) {
				placed_circles[1,.] = (x, 0, radius)
			}
			else {
				placed_circles = placed_circles \ (x, 0, radius)
			}
			
			return (placed_circles)
		}
						
		indexlist = (1..rows(placed_circles))  // this provides a sequence for row combinations

		combolist = combination(indexlist,2)  // this has the combinations		
					
		mhd = .
		lead_candidate = .
		
		
		for (i=1; i <= rows(combolist); i++) {	
			
			c1 = placed_circles[combolist[i,1],.]
			c2 = placed_circles[combolist[i,2],.]
		
		    eps = 1e-9
			margin = radius * eps * 10
			
			real vector othercircles
			othercircles = othervalues(indexlist, combolist[i,.])
			
			other_circles = J(1,3,.)
			
			if (rows(othercircles) >= 1) {
				other_circles = placed_circles[(othercircles),.]
			}
				
			placed_candidates = get_placement_candidates(radius, c1, c2, margin)

			for (j=1; j <= rows(placed_candidates); j++) {
			
			 	if (placed_candidates[j,.]==.) continue
				
				if (other_circles[1,1]==.) {		
					lead_candidate = placed_candidates[j,.]
					break
				}
			
				// Vectorized distance calculation (replaces loop)
				mydist = distance_vec(other_circles, placed_candidates[j,.])
				

				if (any(mydist :< 0)) continue

				
				hd = get_hole_degree_radius_w(placed_candidates[j,.], other_circles)

				
				if (mhd==. | hd < mhd) {
					mhd = hd
					lead_candidate = placed_candidates[j,.]
				}
				
				if (abs(mhd) < margin) break
			
			}
		}
		
		placed_circles = placed_circles \ lead_candidate
	
		return (placed_circles)
	}
end	
	


***********************
// 	 combination     //  // extracted from "tuples" by Luchman, Klein, Cox (v 4.2.0, 2021)
***********************

cap mata mata drop combination()

mata:
	real matrix combination(real vector c1, real scalar r)   // n, r
	{
		real scalar num, combos, i
		
		num = length(c1)
		combos = comb(num,r)	
		output = J(combos,r,.)	

		nmr = num - r
		index = 1
		j = ((i=1)..r)		
				
		while (i) {			
			while (i < r) j[i+1] = j[i++] + 1
				i = r		
				
				while (j[i] >= nmr + i) if (!(--i)) break
				output[index, .] = j
				if (i) j[i] = j[i] + 1			
				++index	
		}
		
		return(output)
	}
end	
	
	
***********************
// 	 othervalues     //  subtract a sublist b from a and identify the remaining values
***********************	
	
cap mata mata drop othervalues()	

mata
	function othervalues(real vector a, real vector b)
	{
		real matrix mylist
		mylist = a
		
		for (i=1; i<=rows(b); i++) mylist = select(mylist, mylist:!=b[i])
		
		return(mylist)
	}    	
end		
	

***********************************
// 	  get_placement_candidates   //  
***********************************

cap mata mata drop get_placement_candidates()

mata
	function get_placement_candidates(radius, c1, c2, margin)   // circles 1 and 2
	{	
    	
		ic1 = c1
		ic1[.,3] = ic1[.,3] :+ (radius + margin)
		
		ic2 = c2
		ic2[.,3] = ic2[.,3] :+ (radius + margin)

	
		i1 = get_intersection(ic1, ic2)[1,.]
		i2 = get_intersection(ic1, ic2)[2,.]
	
		if (i1 == .) return (J(2,3,.))
		
		i1_x = i1[.,1]
		i1_y = i1[.,2]
		
		candidate1 = (i1_x, i1_y, radius)
		
		if (i2 == .) return (candidate1 \ J(1,3,.))
		
		i2_x = i2[.,1] 
		i2_y = i2[.,2]
		
		candidate2 = (i2_x, i2_y, radius)
		
		return (candidate1 \ candidate2)
	
	}
end
		
	
*****************************
// 	  get_intersection     //  
*****************************

cap mata mata drop get_intersection()

mata
	function get_intersection(c1, c2)   // circles 1 and 2
	{	
		real scalar x1, y1, r1
		real scalar x2, y2, r2
		
		
		x1 = c1[1]; y1 = c1[2]; r1 = c1[3]
		x2 = c2[1]; y2 = c2[2]; r2 = c2[3]	
	
		dx = x2 - x1
		dy = y2 - y1
	
		d = sqrt(dx * dx + dy * dy)
		
		a = (r1 * r1 - r2 * r2 + d * d) / (2 * d)
		h = sqrt(r1 * r1 - a * a)
	
	
		xm = x1 + a * dx / d
		ym = y1 + a * dy / d
		
		xs1 = xm + h * dy / d
		xs2 = xm - h * dy / d
		
		ys1 = ym - h * dx / d
		ys2 = ym + h * dx / d
		
		if ((xs1 == xs2) & (ys1 == ys2)) {
			return (xs1, ys1 \  ., .)
		}
		
		
		return (xs1, ys1 \ xs2, ys2)	
		
	}
		
end		
	
	
*********************
// 	  distance     //  
*********************

cap mata mata drop distance()

mata
	function distance(c1, c2)   // circles 1 and 2
	{	
		x1 = c1[1]; y1 = c1[2]; r1 = c1[3]
		x2 = c2[1]; y2 = c2[2]; r2 = c2[3]	
		
		x = x2 - x1
		y = y2 - y1
		
		return (sqrt(x * x + y * y) - r1 - r2)
	}
end


***************************
// 	  distance_vec     //  Vectorized distance calculation
***************************

cap mata mata drop distance_vec()

mata
	function distance_vec(circles, candidate)   // matrix of circles vs single candidate
	{
		real matrix dx, dy, dist
		real scalar cx, cy, cr
		
		cx = candidate[1]
		cy = candidate[2]
		cr = candidate[3]
		
		// Vectorized: all distances at once
		dx = circles[.,1] :- cx
		dy = circles[.,2] :- cy
		dist = sqrt(dx:^2 :+ dy:^2) :- circles[.,3] :- cr
		
		return(dist)
	}
end	

*************************************
// 	  get_hole_degree_radius_w     //  
*************************************

cap mata mata drop get_hole_degree_radius_w()

mata
	function get_hole_degree_radius_w(candidate, circles)   // 
	{		
		real scalar space_score, mysum, avg_spacing
		real matrix distances
		
		// Vectorized distance calculation (replaces loop)
		distances = distance_vec(circles, candidate)
		
		// Original metric: distance weighted by circle radius (vectorized)
		mysum = sum(distances :* circles[.,3])
		
		// Enhanced metric: favor placements with better space availability
		// Penalize placements too close to other circles (less room for growth)
		avg_spacing = mean(distances)
		space_score = mysum + avg_spacing * 0.5
		
		return (space_score)
	}
end
	
	

********************
// 	  enclose     //  
********************

cap mata mata drop enclose()

mata
	function enclose(circles)   // 
	{

    B = J(1,3,0)
	e = J(1,3,.)

    n = rows(circles)
    i = 1
    while (i <= n) {
        p = circles[i,.]
		
		if (e!=. & enclosesWeak(e, p)) {
            i = i + 1
		}
        else {    			
			B = extendBasis(B, p)
			e = encloseBasis(B)
            i = 1
		}
	}
	
    return (e)

	}
end	
	
*************************
// 	  enclosesWeak     //  
*************************

cap mata mata drop enclosesWeak()

mata
	function enclosesWeak(a, b)   
	{			
		dx = b[1] - a[1]
		dy = b[2] - a[2]
		dr = a[3] - b[3] + 1e-6
		return (dr > 0 & dr * dr > dx * dx + dy * dy)
	}
end			



************************
// 	  extendBasis     //  
************************

cap mata mata drop extendBasis()

mata
	function extendBasis(B, p)   // 
	{		

    if (enclosesWeakAll(p, B)) {
		return (p)	
	}

	for (i=1; i <= rows(B); i++) {
        if (enclosesNot(p, B[i,.]) & enclosesWeakAll(encloseBasis2(B[i,.], p), B)) {
			return (B[i,.] \ p)
		}
	}
	
	
	for (i = 1; i <= rows(B) - 1; i++) {	
		for (j = i + 1; j <= rows(B); j++) {	
			if (enclosesNot(encloseBasis2(B[i,.], B[j,.]), p)  & enclosesNot(encloseBasis2(B[i,.], p), B[j,.]) & enclosesNot(encloseBasis2(B[j,.], p), B[i,.]) & enclosesWeakAll(encloseBasis3(B[i,.], B[j,.], p), B)) {
				return (B[i,.] \ B[j,.] \ p)
			}
			
		}
	}
	}
end		
	


****************************
// 	  enclosesWeakAll     //  
****************************

cap mata mata drop enclosesWeakAll()

mata
	function enclosesWeakAll(a, B)   // 
	{		
		
		for (i=1; i <= rows(B); i++) {
			if (!enclosesWeak(a, B[i,.])) return (0)
		} 
		return (1)

	}
end			
	

************************
// 	  enclosesNot     //  
************************

cap mata mata drop enclosesNot()

mata
	function enclosesNot(a, b)   // 
	{			
    
    dx = b[1] - a[1]
    dy = b[2] - a[2]
    dr = a[3] - b[3]
	
	return ((dr < 0) | ((dr * dr) < (dx * dx + dy * dy)))		
	}
end		
	

*************************
// 	  encloseBasis     //  
*************************

cap mata mata drop encloseBasis()

mata
	function encloseBasis(B)   // 
	{		
		if (rows(B) == 1) {
			return (B[1,.])
		}
		else if (rows(B) == 2) {
			return (encloseBasis2(B[1,.], B[2,.]))
		}
		else {
			return (encloseBasis3(B[1,.], B[2,.], B[3,.]))
		}
	}
end	
	
	


**************************
// 	  encloseBasis2     //  
**************************

cap mata mata drop encloseBasis2()

mata
	function encloseBasis2(a,b)   // 
	{	
		x1 = a[1] ; y1 = a[2] ; r1 = a[3] 
		x2 = b[1] ; y2 = b[2] ; r2 = b[3]
		

		x21 = x2 - x1
		y21 = y2 - y1
		r21 = r2 - r1
		l21 = sqrt(x21 * x21 + y21 * y21)
    
		return ((x1 + x2 + x21 / l21 * r21) / 2, (y1 + y2 + y21 / l21 * r21) / 2, (l21 + r1 + r2) / 2)

	
	}
end	


**************************
// 	  encloseBasis3     //  
**************************

cap mata mata drop encloseBasis3()

mata
	function encloseBasis3(a,b,c)   // 
	{
		x1 = a[1] ; y1 = a[2] ; r1 = a[3] 
		x2 = b[1] ; y2 = b[2] ; r2 = b[3]		
		x3 = c[1] ; y3 = c[2] ; r3 = c[3]
		
		
		a2 = x1 - x2
		a3 = x1 - x3
		b2 = y1 - y2
		b3 = y1 - y3
		c2 = r2 - r1
		c3 = r3 - r1
		d1 = x1 * x1 + y1 * y1 - r1 * r1
		d2 = d1 - x2 * x2 - y2 * y2 + r2 * r2
		d3 = d1 - x3 * x3 - y3 * y3 + r3 * r3
		ab = a3 * b2 - a2 * b3
		xa = (b2 * d3 - b3 * d2) / (ab * 2) - x1
		xb = (b3 * c2 - b2 * c3) / ab
		ya = (a3 * d2 - a2 * d3) / (ab * 2) - y1
		yb = (a2 * c3 - a3 * c2) / ab
		A = xb * xb + yb * yb - 1
		B = 2 * (r1 + xa * xb + ya * yb)
		C = xa * xa + ya * ya - r1 * r1
			
		if (A != 0) {
			r = -(B + sqrt(B * B - 4 * A * C)) / (2 * A)
		}
		else {
			r = -C / B
		}
		
		return (x1 + xa + xb * r, y1 + ya + yb * r, r)
	}
end		


******************
// 	  scale     //  
******************

cap mata mata drop scale()

mata
	function scale(circle, target, enclosure)   // 
	{

    r = target[.,3] / enclosure[.,3]
    
	t_x = target[.,1]
	t_y = target[.,2]
	
	e_x = enclosure[.,1]
	e_y = enclosure[.,2]
	

	c_x = circle[.,1]
	c_y = circle[.,2]
	c_r = circle[.,3]
	
	
    return ((c_x :- e_x) :* r :+ t_x, (c_y :- e_y) :* r :+ t_y, c_r :* r)


	}
end	


**********************
//  returnbounds	//		
**********************

cap mata: mata drop returnbounds()
mata:  // returnbounds
	function returnbounds(data, a, o) //  // x, y, r, angle, obs
	{
		theta  = J(o,1,.)
		
		for (i=1; i <= o; i++) {	
			theta[i] = i * -2 * pi() / o
		}
		
		coords = cos(theta) :* data[.,3], sin(theta) :* data[.,3]
		ro = -1 * a * pi() / 180
		rotation = (cos(ro), -sin(ro) \ sin(ro), cos(ro))
		coords = (coords * rotation') :+ (data[.,1], data[.,2])

		return(coords)	
	}
end


**********************
//  getcoords	//		
**********************

cap mata: mata drop getcoords()
mata:  // getcoords
	function getcoords(data, angle, obs)  // x, y, r, angle, obs
	{
		coords = J(obs, rows(data) * 2, .)

		for (i=1; i <= rows(data); i++) {
			b = i * 2
			a = b - 1
			coords[.,a..b] = returnbounds(data[i,.], angle, obs)		
		}
	
		return (coords)
	}
end


**********************
//   getcoords2	    //		
**********************

cap mata: mata drop getcoords2()
mata:  // getcoords
	function getcoords2(data, angle, obs)  // x, y, r, angle, obs
	{
		coords = J(obs * rows(data), 4, .)  // x, y, id, maxy

		for (i=1; i <= rows(data); i++) {
			b = i * obs
			a = b - (obs - 1)
			
			coords[a::b, 1..2] = returnbounds(data[i,.], angle, obs)
			coords[a::b, 3] = J(obs,1,i)
			coords[i, 4] =  max(select(coords[.,2], coords[.,3] :== i))		

		}
	
		return (coords)
	}
end





*******************
*******************
***		        ***
***		END     ***
***		        ***
*******************
*******************

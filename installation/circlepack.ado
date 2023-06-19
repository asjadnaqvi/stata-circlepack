*! circlepack v1.1 (16 May 2023) 
*! Asjad Naqvi (asjadnaqvi@gmail.com)

*v1.1  (16 May 2023): Major update. Several features added to make it more compatible with treemap.
*v1.01 (24 Nov 2022): Minor fixes to prevent duplicate value errors. Checks for 0s and negatives. Improved precision.
*v1.0  (08 Sep 2022): First release.


cap prog drop circlepack

prog def circlepack, sortpreserve

	version 15
	
	syntax varlist(numeric max=1) [if] [in], by(varlist min=1 max=3)	 ///   
		[ pad(real 0.1) angle(real 0) points(real 60) circle0 circle0c(string) format(str) palette(string) ADDTitles NOVALues NOLABels cond(string)  ]		///
		[ LABColor(string) title(passthru) subtitle(passthru) note(passthru) scheme(passthru) name(passthru) ] ///
		[ share THRESHold(numlist max=1 >=0) labprop labscale(real 0.5) LABSize(string) titleprop  fi(numlist max=3) labcond(real 0) ]  // v1.1 options
	
	marksample touse, strok
	
	
	// check for dependencies
	cap findfile carryforward.ado
	if _rc != 0 {
		qui ssc install carryforward, replace
	}		
	

qui {	
preserve	
	keep if `touse'
	
	qui summ `varlist', meanonly
	if r(min) <= 0 noi di in yellow "`varlist' contains zeros or negative values. These have been dropped."
	drop if `varlist' <= 0	
	
	local length : word count `by'
	
	if `length' == 1 {
		local var0 `by'
		
		cap confirm string var `var0'
			if _rc!=0 {
				gen var0_temp = string(`var0')
				local var0 var0_temp
			}
		
		collapse (sum) `varlist', by(`var0') 
		
		if "`threshold'"!="" {
			replace `var0' = "Rest of `var0'" if `varlist' <= `threshold'
		}
		
		collapse (sum) `varlist', by(`var0') 		
		
		
		gen double var0_v = `varlist'
		gsort -var0_v `var0'  // stabilize the sort
	}

	if `length' == 2 {
		tokenize `by'
		local var0 `1'
		local var1 `2'
		
		cap confirm string var `var0'
			if _rc!=0 {
				gen var0_temp = string(`var0')
				local var0 var0_temp
			}
			
		cap confirm string var `var1'
			if _rc!=0 {
				gen var1_temp = string(`var1')
				local var1 var1_temp
			}	
		
		collapse (sum) `varlist', by(`var0' `var1') 
		
		if "`threshold'"!="" {
			levelsof `var0', local(lvls)
			foreach x of local lvls {
				replace `var1' = "Rest of `x'" if `varlist' <= `threshold' & `var0'=="`x'"
			}
		}
		
		collapse (sum) `varlist', by(`var0' `var1') 

		bysort `var0': egen var0_v = sum(`varlist')
		gen double var1_v = `varlist'

		gsort -var0_v -var1_v
		
	}	
	

	if `length' == 3 {
		tokenize `by'
		local var0 `1'
		local var1 `2'
		local var2 `3'
		
		cap confirm string var `var0'
			if _rc!=0 {
				gen var0_temp = string(`var0')
				local var0 var0_temp
			}
			
		cap confirm string var `var1'
			if _rc!=0 {
				gen var1_temp = string(`var1')
				local var1 var1_temp
			}	
			
		cap confirm string var `var2'
			if _rc!=0 {
				gen var2_temp = string(`var2')
				local var2 var2_temp
			}				
		
		
		if "`threshold'"!="" {
			levelsof `var1', local(lvls)
			foreach x of local lvls {
				replace `var2' = "Rest of `x'" if `varlist' <= `threshold' & `var1'=="`x'"
			}
		}
		
		collapse (sum) `varlist', by(`var0' `var1' `var2')
		
		bysort `var0': egen var0_v = sum(`varlist')
		bysort `var1': egen var1_v = sum(`varlist')
		gen double var2_v = `varlist'
		
		gsort -var0_v -var1_v -var2_v
	}
	

	gen id = _n		

	** the highest level is sorted highest to lowest

	egen var0_t = tag(`var0')
	gen  double var0_o = sum(`var0' != `var0'[_n-1]) 
	
	if `length' > 1 {
			
		egen var1_t = tag(`var0' `var1')

		gsort `var0' -var1_t -var1_v 
		cap drop var1_o
		bysort `var0': gen var1_o = _n if var1_t==1
		sort id
		carryforward var1_o, replace
	}

	if `length' > 2 {	
		sort `var1' id 
		by `var1': gen var2_o = _n
		gen var2_t = 1	
	}

	sort id
	
	// set up the base values
	
	local radius = 10 // this radius is hardcoded
	mata: eps = 1e-9; enclosure0 = (0, 0, `radius'); angle = `angle'; pad = `pad'; obs = `points'
	
	if "`format'"  == "" {
		if "`share'"  == "" {
			local format %12.0fc
		}
		else {
			local format %5.2f
		}
	}

	**********************
	** process level 0  **
	**********************

		mata data = select(st_data(., ("var0_v")), st_data(., "var0_t=1"))
		mata datasum = sum(data[.,1])
		mata c0 = _circlify_level(data, enclosure0); p0 = getcoords2(c0, angle, obs)
		mata st_matrix("p0", p0)	
		mata st_matrix("p0_lab", (c0[.,1..2], data, data :/ datasum))

		
	**********************
	** process level 1  **
	**********************

	if `length' > 1 {
	
	mata c0[.,3] = c0[.,3] :- pad 

	levelsof var0_o, local(l0)
	foreach i of local l0 { 

			mata mydata = select(st_data(., ("var1_v", "var0_o")), st_data(., "var1_t = 1"))
			mata mydata = select(mydata[.,1], mydata[.,2] :== `i')		
			mata c1_`i' = _circlify_level(mydata, c0[`i',.]); p1_`i' = getcoords2(c1_`i', angle, obs)			
			mata st_matrix("p1_`i'", p1_`i')	
			mata st_matrix("p1_`i'_lab", (c1_`i'[.,1..2], mydata, mydata :/ datasum))
		}		
	}
	
	
	**********************
	** process level 2  **
	**********************

	if `length' > 2 {	
	
		levelsof var0_o, local(l0)
		foreach i of local l0 {

			mata c1_`i'[.,3] = c1_`i'[.,3] :- pad

			levelsof var1_o if var0_o==`i', local(l1)
			foreach j of local l1 {
			
				mata mydata = select(st_data(., ("var2_v", "var0_o", "var1_o")), st_data(., "var2_t = 1"))
				mata mydata = select(mydata[.,1], mydata[.,2] :== `i' :& mydata[.,3] :== `j')		
				mata c2_`i'_`j' = _circlify_level(mydata, c1_`i'[`j',.]); p2_`i'_`j' = getcoords2(c2_`i'_`j', angle, obs)
				mata st_matrix("p2_`i'_`j'", p2_`i'_`j')				
				mata st_matrix("p2_`i'_`j'_lab", (c2_`i'_`j'[.,1..2], mydata, mydata :/ datasum))
			}
		}	
	}
	
	

*************************************
***  convert data to coordinates  ***
*************************************

	// finish up in Stata
	
	*** level 0
	
	cap drop _*
	local varlist 

	
	mat colnames p0 = "_l0_x" "_l0_y" "_l0_id" "_l0_ymax"
	svmat p0, n(col)
	
	// level 0 labels
	mat colnames p0_lab = "_l0_xmid" "_l0_ymid" "_l0_val" "_l0_share"
	svmat p0_lab, n(col)
	
	gen _l0_lab1 = ""
	
	levelsof var0_o, local(l0)
	local item0 = `r(r)'
	foreach i of local l0  {
	
		sum id if var0_o == `i' & var0_t == 1, meanonly
		replace _l0_lab1 = `var0'[r(mean)] in `i'  if _l0_val >= `labcond'
	}

	local mylab cond("`share'"=="", _l0_val, _l0_share * 100)
	
	if "`share'"=="" {
		gen  _l0_lab0 = "{it:" + _l0_lab1 + " (" + string(`mylab', "`format'") + ")}" in 1/`item0' if _l0_val >= `labcond'  
		gen  _l0_lab2 = string(`mylab', "`format'") in 1/`item0'  if _l0_val >= `labcond' 
	}
	else {
		gen  _l0_lab0 = "{it:" + _l0_lab1 + " (" + string(`mylab', "`format'") + "%)}" in 1/`item0'  if _l0_val >= `labcond'
		gen  _l0_lab2 = string(`mylab', "`format'") + "%" in 1/`item0'  if _l0_val >= `labcond' 
	}
	
	*** level 1
	
	if `length' > 1 {	
	
		levelsof var0_o, local(l0)
		foreach i of local l0  {
			
		
		mat colnames p1_`i' = "_l1_`i'_x" "_l1_`i'_y" "_l1_`i'_id" "_l1_`i'_ymax"
		svmat p1_`i', n(col)
		
		
		// level 1 labels
		mat colnames p1_`i'_lab = "_l1_`i'_xmid" "_l1_`i'_ymid" "_l1_`i'_val" "_l1_`i'_share"
		svmat p1_`i'_lab, n(col)
		
		gen _l1_`i'_lab1 = ""
			
			levelsof var1_o if var0_o==`i', local(l1)
			local item1 = `r(r)'
			foreach j of local l1  {
				
				sum id if var0_o == `i' & var1_o == `j' & var1_t == 1, meanonly
				replace _l1_`i'_lab1 = `var1'[r(mean)] in `j'   if _l1_`i'_val >= `labcond'
			}
		
		local mylab cond("`share'"=="", _l1_`i'_val, _l1_`i'_share * 100)			
		
			if "`share'"=="" {
				gen  _l1_`i'_lab0 = "{it:" + _l1_`i'_lab1 + " (" + string(`mylab', "`format'") + ")}"  in 1/`item1' if _l1_`i'_val >= `labcond' 
				gen  _l1_`i'_lab2 = string(`mylab', "`format'")  in 1/`item1'  if _l1_`i'_val >= `labcond' 
			}
			else {
				gen  _l1_`i'_lab0 = "{it:" + _l1_`i'_lab1 + " (" + string(`mylab', "`format'") + "%)}"  in 1/`item1' if _l1_`i'_val >= `labcond'  
				gen  _l1_`i'_lab2 = string(`mylab', "`format'") + "%"  in 1/`item1'  if _l1_`i'_val >= `labcond' 
			}
		}
	}
	
	
	*** level 2
	
	if `length' > 2 {	
	
		levelsof var0_o, local(l0)
		foreach i of local l0  {
			
			levelsof var1_o if var0_o==`i', local(l1)
			foreach j of local l1  {	
				
			
			mat colnames p2_`i'_`j' =  "_l2_`i'_`j'_x" "_l2_`i'_`j'_y" "_l2_`i'_`j'_id" "_l2_`i'_`j'_ymax"
			svmat p2_`i'_`j', n(col)
			
			mat colnames p2_`i'_`j'_lab = "_l2_`i'_`j'_xmid" "_l2_`i'_`j'_ymid" "_l2_`i'_`j'_val" "_l2_`i'_`j'_share"
			svmat p2_`i'_`j'_lab, n(col)
			
			gen _l2_`i'_`j'_lab1 = ""
			
			levelsof var2_o if var0_o==`i' & var1_o==`j' & var2_t==1, local(l2)
			local item2 = `r(r)'		
					foreach k of local l2  {	
						
						sum id if var0_o == `i' & var1_o==`j'& var2_o==`k' &  var2_t == 1, meanonly
						replace _l2_`i'_`j'_lab1 = `var2'[r(mean)] in `k'  if _l2_`i'_`j'_val >= `labcond'
					}
			
			
				local mylab cond("`share'"=="", _l2_`i'_`j'_val, _l2_`i'_`j'_share * 100)	
				
				if "`share'"=="" {
					gen  _l2_`i'_`j'_lab0 = "{it:" + _l2_`i'_`j'_lab1 + " (" + string(`mylab', "`format'") + ")}"  in 1/`item2' if _l2_`i'_`j'_val >= `labcond'
					gen  _l2_`i'_`j'_lab2 = string(`mylab', "`format'") in 1/`item2'  if _l2_`i'_`j'_val >= `labcond'
				}
				else {
					gen  _l2_`i'_`j'_lab0 = "{it:" + _l2_`i'_`j'_lab1 + " (" + string(`mylab', "`format'") + "%)}"  in 1/`item2' if _l2_`i'_`j'_val >= `labcond'
					gen  _l2_`i'_`j'_lab2 = string(`mylab', "`format'") + "%" in 1/`item2'  if _l2_`i'_`j'_val >= `labcond'
				}			
			
			
			
			}	
		}
	}
	
	
***************	
***  draw	***
***************

	if "`palette'" == "" {
		local palette tableau
	}
	else {
		tokenize "`palette'", p(",")
		local palette `1'
		local poptions `3'
	}

	*** draw the layers ***
	
	// control the fill intensities
	
	if "`fi'" != "" {
		tokenize `fi'
		local filen : word count `fi'
		
		local fi2 `1'
		local fi1 `1'
		local fi0 `1'

		if `filen' > 1 {
			local fi1 `2'
			local fi2 `2'
		}
			
		if `filen' > 2 {
			local fi1 `2'
			local fi2 `3'
		}
	}
	else {
		local fi0 100
		
		if `length' == 2 {
			local fi0 = 60
			local fi1 = 90
		}	
		
		if `length' == 3 {
			local fi0 = 50
			local fi1 = 75
			local fi2 = 100
		}	
	}	

	if "`labsize'" != "" {
		tokenize `labsize'
		local lslen : word count `labsize'
		
		local ls0 `1'
		local ls1 `1'
		local ls2 `1'

		if `lslen' > 1 {
			local ls1 `2'
			local ls2 `2'
		}
			
		if `lslen' > 2 {
			local ls1 `2'
			local ls2 `3'
		}
	}
	else {
		local ls0 2
		local ls1 2
		local ls2 2
	}		
	
	
	if "labcolor" == "" local labcolor black

	
	***************
	*** level 0 ***
	***************
	
	
	levelsof var0_o, local(l0)
	local lvl0 = `r(r)'
	
	foreach i of local l0  {	
	
			if "`titleprop'" != "" {
				local labt0 = max((2 * `ls0' * _l0_share[`i']^`labscale'),0)
			}
			else {
				local labt0 = `ls0'
			}	
			
			if "`labprop'" != "" {
				local labs0 = (2 * `ls0' * _l0_share[`i']^`labscale')
			}
			else {
				local labs0 = `ls0'
			}	
		
		colorpalette `palette', nograph n(`lvl0') `poptions'
		
		local c0 `c0' (area _l0_y _l0_x if _l0_id==`i', nodropbase fi(`fi0') fc("`r(p`i')'") lc(black) lw(0.03)) ||

		local c0_box `c0_box' (scatter _l0_ymax _l0_xmid in `i', mc(none) mlab(_l0_lab0) mlabpos(12) mlabgap(0.8) mlabsize(`labt0') mlabc(`labcolor')) 
		
		local c0_lab `c0_lab' (scatter _l0_ymid _l0_xmid in `i', mc(none) mlab(_l0_lab1) mlabpos(0)               mlabsize(`labs0') mlabc(`labcolor') ) || 
	
		if "`novalues'" == "" local c0_lab `c0_lab'  (scatter _l0_ymid _l0_xmid in `i', mc(none) mlab(_l0_lab2) mlabgap(0) mlabpos(6) mlabsize(`labs0') mlabc(`labcolor') )
			
		
	}
	



	***************
	*** level 1 ***
	***************
	
	if `length' > 1 {	
	
		levelsof var0_o, local(l0)
		foreach i of local l0  {
			
			levelsof var1_o if var0_o==`i', local(l1)
			foreach j of local l1  {
			
				if "`titleprop'" != "" {
					local labt1 = max((2 * `ls1' * _l1_`i'_share[`j']^`labscale'),0)
				}
				else {
					local labt1 = `ls1'
				}				
							
				if "`labprop'" != "" {
					local labs1 = max((2 * `ls1' * _l1_`i'_share[`j']^`labscale'),0)
				}
				else {
					local labs1 = `ls1'
				}			
				
				colorpalette `palette', nograph n(`lvl0') `poptions'
				
				local c1 `c1' (area _l1_`i'_y _l1_`i'_x  if _l1_`i'_id==`j', nodropbase fi(`fi1') fc("`r(p`i')'") lc(black) lw(0.03)) ||

				local c1_box `c1_box' (scatter _l1_`i'_ymax _l1_`i'_xmid  in `j', mc(none) mlab(_l1_`i'_lab0) mlabpos(12) mlabgap(0) mlabsize(`labt1') mlabc(`labcolor') ) 
					
				local c1_lab `c1_lab' (scatter _l1_`i'_ymid _l1_`i'_xmid  in `j', mc(none) mlab(_l1_`i'_lab1) mlabpos(0) mlabsize(`labs1') mlabc(`labcolor') ) || 
		
				if "`novalues'" == "" local c1_lab `c1_lab' (scatter _l1_`i'_ymid _l1_`i'_xmid  in `j', mc(none) mlab(_l1_`i'_lab2) mlabpos(6) mlabgap(0) mlabsize(`labs1') mlabc(`labcolor') ) ||
					

			}
		}
	}
	
	***************
	*** level 2 ***
	***************

	
	if `length' > 2 {	
	
	levelsof var0_o, local(l0)
		foreach i of local l0  {
			
			levelsof var1_o if var0_o==`i', local(l1)
			foreach j of local l1  {	
							
				levelsof var2_o if var0_o==`i' & var1_o==`j', local(l2)
				foreach k of local l2  {	
				
					
				
					if "`labprop'" != "" {
						local labs2 = max((2 * `ls2' * _l2_`i'_`j'_share[`k']^`labscale'),0)
					}
					else {
						local labs2 = `ls2'
					}				
					


					colorpalette `palette', nograph n(`lvl0') `poptions'
					
					local c2 `c2' (area _l2_`i'_`j'_y _l2_`i'_`j'_x if _l2_`i'_`j'_id==`k', nodropbase fi(`fi2') fc("`r(p`i')'") lc(black) lw(0.03)) ||
		
					local c2_lab `c2_lab' (scatter _l2_`i'_`j'_ymid _l2_`i'_`j'_xmid in `k', mc(none) mlab(_l2_`i'_`j'_lab1) mlabpos(0) mlabsize(`labs2') mlabc(`labcolor') ) || 
			
					if "`novalues'" == "" local c2_lab `c2_lab' (scatter _l2_`i'_`j'_ymid _l2_`i'_`j'_xmid in `k', mc(none) mlab(_l2_`i'_`j'_lab2) mlabpos(6) mlabgap(0) mlabsize(`labs2') mlabc(`labcolor') ) ||
				
				}
			}
		}
	}
	
	
	if "`circle0c'" == "" local circle0c gs15
	
	if "`circle0'" != "" {
		
		local r0 = `radius' + `pad'
		
		local circle0  (function  sqrt(`r0'^2 - (x)^2), recast(area) fi(100) fc(`circle0c')  lw(none)  range(-`r0' `r0'))  || (function  -sqrt(`r0'^2 - (x)^2), recast(area) fi(100) fc(`circle0c') lw(none) range(-`r0' `r0')) 
		
	}
	
	
	
	****************
	***   plot   ***
	****************
 
 
	if `length' == 3 {
		local mylab  `c2_lab'	
		if "`addtitles'" != "" local boxlab `c1_box' || `c0_box'
	} 
	else if `length' == 2 {
		local mylab  `c1_lab'
		if "`addtitles'" != "" local boxlab `c0_box'
	}
	else {
		local mylab  `c0_lab'
		local boxlab
	}
 
 
	if "`nolabels'" != "" local mylab
 
 
	twoway ///
		`circle0' ///
		`c0' ///
		`c1' ///
		`c2' ///
		`mylab' ///
		`boxlab' ///		
			, ///
			legend(off) ///
			xscale(off) yscale(off) ///
			aspect(1) xsize(1) ysize(1) ///
			xlabel(-`radius' `radius', nogrid) ylabel(-`radius' `radius', nogrid) ///
				`title' `subtitle' `note' `scheme' `name'
			
	

restore		
}		

end


***************************
*** Mata sub-routines   ***
***************************



****************************
// 	  _circlify_level     //  
****************************

cap mata mata drop _circlify_level()

mata
	function _circlify_level(data, target_enclosure)   // 
	{
		all_circles = J(rows(data), 3, .)
		packed  = pack_A1_0(data)
		enclosure = enclose(packed)
		scaled = scale(packed, target_enclosure, enclosure)    
		return (scaled)

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
			
				mydist = J(rows(other_circles), 1, .)
		
				for (k=1; k <= rows(other_circles); k++) {
					mydist[k] = distance(other_circles[k,.], placed_candidates[j,.])	
				}
				

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

*************************************
// 	  get_hole_degree_radius_w     //  
*************************************

cap mata mata drop get_hole_degree_radius_w()

mata
	function get_hole_degree_radius_w(candidate, circles)   // 
	{		
		real scalar mysum
		mysum = 0
		
		for (i=1; i <= rows(circles); i++) {
			mysum = mysum + (distance(candidate, circles[i,.]) * circles[i,3]) 
		}
		
		return (mysum)
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

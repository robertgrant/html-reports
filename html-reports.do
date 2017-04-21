/*
	Stata commands for writing output to HTML reports
	Robert Grant, 2015-17
	robertgrantstats.co.uk and github.com/robertgrant
	This work is licensed under a Creative Commons Attribution 4.0 International License: 
	creativecommons.org/licenses/by/4.0/
*/

/* To do:
	all functions except start: include id option
	unitab: Include row label for missing string values and a % non-missing column
	multitab: % of responses (already there), % of all observations (to add)
	unitab and multitab option to align numbers (centre as default)
	write table of descriptive stats, given the data
*/

/* Notes:
	If you really do want a blank html title, use projecttitle(" ") in html_start
	We assume the file is already open, in line with the html-reports.R functions
	It's up to the user to insert the </a> after starting blocking in html_p
*/

// initiate HTML file to hold output
capture program drop html_start
program define html_start
	syntax [, Handle(string) Projecttitle(string) No_h1 Blocking(string)]
	// defaults
	if "`handle'"=="" {
		local handle "con"
	}
	if "`projecttitle'"=="" {
		local projecttitle "My project"
	}
	//capture file close `handle'
	//file open `handle' using "html/COTS-1-output.html", write text replace
	file write `handle' "<!DOCTYPE html>" _n
	file write `handle' "<html>" _n
	file write `handle' "<head>" _n
	file write `handle' "<meta name='description' content='Stata output written to HTML using "
	file write `handle' "the html-reports commands by Robert Grant (github.com/robertgrant"
	file write `handle' "/html-reports)'>" _n
	file write `handle' "<title>`projecttitle'</title>" _n
	file write `handle' "<style>" _n
	file write `handle' _tab "body {" _n
	file write `handle' _tab _tab "max-width: 900px;" _n
	file write `handle' _tab "}" _n
	file write `handle' _tab "h1, h2, h3, p, ol, ul {" _n
	file write `handle' _tab _tab "font-family: 'Helvetica';" _n
	file write `handle' _tab "}" _n
	file write `handle' _tab "p.caption {" _n
	file write `handle' _tab _tab "font-size: 75%;" _n
	file write `handle' _tab _tab "font-style: italic;" _n
	file write `handle' _tab "}" _n
	file write `handle' _tab "table, th {" _n
	file write `handle' _tab _tab "border-bottom: 1px solid black;" _n
	file write `handle' _tab _tab "border-top: 1px solid black;" _n
	file write `handle' _tab _tab "border-collapse: collapse;" _n
	file write `handle' _tab _tab "font-family: 'Helvetica';" _n
	file write `handle' _tab "}" _n
	file write `handle' _tab "td, tr {" _n
	file write `handle' _tab _tab "border-collapse: collapse;" _n
	file write `handle' _tab _tab "padding-left: 15px;" _n
	file write `handle' _tab _tab "padding-right: 15px;" _n
	file write `handle' _tab _tab "padding-top: 5px;" _n
	file write `handle' _tab _tab "padding-bottom: 5px;" _n
	file write `handle' _tab _tab "font-family: 'Helvetica';" _n
	file write `handle' _tab _tab "text-align: center;" _n
	file write `handle' _tab "}" _n
	file write `handle' _tab _tab "table th.subhead { border-left: 1px solid #000; }" _n
	file write `handle' _tab "tr:nth-child(even) {" _n
	file write `handle' _tab _tab "background-color: #f2f2f2;" _n
	file write `handle' _tab "}" _n
	file write `handle' "</style>" _n
	file write `handle' "</head>" _n _n
	// if blocking is specified, assemble the HTML
	if "`blocking'"!="" {
		local blockcode `" onload=""' 
		foreach i of local blocking {
			local blockcode=`"`blockcode'blocking('`i''); "'
		}
		local blockcode=`"`blockcode'""'
	}
	file write `handle' `"<body`blockcode'>"' _n
	if "`no_h1'"=="" {
		file write `handle' "<h1>`projecttitle'</h1>" _n
	}
end
	
	
// this function makes a univariate frequency table in HTML
capture program drop html_unitab
program define html_unitab, rclass
	syntax varname [, CAPtion(string) Handle(string) Tableno(integer 1)]
	// defaults
	if "`handle'"=="" {
		local handle "con"
	}
	preserve
		gen temp=1
		collapse (sum) n=temp, by(`varlist')
		qui count
		local temp=r(N)
		qui summ n
		local temptotal=r(sum)
		file write `handle' "<p class='caption'>Table `tableno': `caption'</p>" _n
		local ++tableno
		file write `handle' "<table><tr><th></th><th>N</th><th>%</th></tr>" _n
		forvalues i=1/`temp' {
			local tempid=`varlist'[`i']
			local tempn=n[`i']
			local tempperc: display %4.1f round(100*`tempn'/`temptotal', 0.1)
			file write `handle' "<tr><td>`tempid'</td><td>`tempn'</td><td>`tempperc'%</td></tr>" _n
		}
		file write `handle' "</table>" _n _n
	restore
	return scalar tableno=`tableno'
end



/* this function makes a multivariate frequency table, with one row for
	each binary 0/1-coded variable, in HTML */
capture program drop html_multitab
program define html_multitab, rclass
	syntax varlist [, CAPtion(string) Handle(string) Tableno(integer 1)]
	// defaults
	if "`handle'"=="" {
		local handle "con"
	}
	file write `handle' "<p class='caption'>Table `tableno': `caption'</p>" _n
	local ++tableno
	file write `handle' "<table><tr><th></th><th>N</th><th>%</th></tr>" _n
	foreach v in `varlist' {
		qui summ `v'
		local tempnum=r(sum)
		local tempdenom=r(N)
		local tempperc: display %4.1f round(100*`tempnum'/`tempdenom',0.1)
		file write `handle' "<tr><td>`v'</td><td>`tempnum'/`tempdenom'</td><td>`tempperc'%</td></tr>" _n
	}
	file write `handle' "</table>" _n _n
	return scalar tableno=`tableno'
end



// this function makes a cross-tabulation
capture program drop html_xtab
program define html_xtab
	syntax varlist(min=2 max=2) , [CAPtion(string) Matrixname(string) Row Col ///
		Handle(string) Tableno(integer 1) ROWLABel(string) COLLABel(string) DP(integer 1) MISsing]
	// defaults and checking
	if "`matrixname'"=="" {
		local matrixname "mymat"
	}
	if "`handle'"=="" {
		local handle "con"
	}
	if "`row'"!="" & "`col'"!="" {
		dis as error "Warning: you specified both row and column percentages but only one is permitted."
		dis as error "Outputting row percentages..."
	}
	local dpround=10^(-1*`dp')
	// put frequencies into matrix
	qui tab `varlist' `if' `in', `missing' matcell(`matrixname') 
	// get names of rows and columns of matrix as well as marginal totals
	tokenize `varlist'
	local rowvar "`1'"
	local colvar "`2'"
	preserve
		tempname tempn
		gen `tempn'=1
		if "`in'"!="" {
			keep `in'
		}
		if "`if'"!="" {
			keep `if'
		}
		collapse (count) `tempn', by(`rowvar')
		if "`missing'"!="missing" {
			capture confirm var string `rowvar'
			if _rc==0 {
				drop if `rowvar'==.
			}
			else {
				drop if `rowvar'==""
			}
		}
		qui count
		local nrownames=r(N)
		forvalues i=1/`nrownames' {
			local rowname`i' = `rowvar'[`i']
			local rowtotal`i' = `tempn'[`i']
		}
	restore
	preserve
		tempname tempn2
		gen `tempn2'=1
		if "`in'"!="" {
			keep `in'
		}
		if "`if'"!="" {
			keep `if'
		}
		collapse (count) `tempn2', by(`colvar')
		if "`missing'"!="missing" {
			capture confirm var string `colvar'
			if _rc==0 {
				drop if `colvar'==.
			}
			else {
				drop if `colvar'==""
			}
		}
		qui count
		local ncolnames=r(N)
		forvalues i=1/`ncolnames' {
			local colname`i' = `colvar'[`i']
			local coltotal`i' = `tempn2'[`i']
		}
	restore
	// get size of matrix
	local nrowvals=rowsof(`matrixname')
	local ncolvals=colsof(`matrixname')
	local nrows=`nrowvals'+3
	local ncols=`ncolvals'+3
	// get variable labels if row/col label have not been specified
	if "`rowlabel'"=="" {
		local rowlabel: variable label `rowvar'
	}
	if "`collabel'"=="" {
		local collabel: variable label `colvar'
	}
	// get percentages, if required
	if "`row'"=="row" {
		matrix percs = `matrixname'
		forvalues i=1/`nrowvals' {
			forvalues j=1/`ncolvals' {
				matrix percs[`i',`j'] = round(100*(`matrixname'[`i',`j'])/(`rowtotal`i''), `dpround')
			}
		}
	}
	else if "`col'"=="col" {
		matrix percs = `matrixname'
		forvalues i=1/`nrowvals' {
			forvalues j=1/`ncolvals' {
				matrix percs[`i',`j'] = round(100*(`matrixname'[`i',`j'])/(`coltotal`j''), `dpround')
			}
		}
	}
	// start writing table
	file write `handle' "<p class='caption'>Table `tableno': `caption'</p>" _n
	local ++tableno
	// write first row
	file write `handle' "<table><tr><th></th><th></th><th colspan='`ncolvals''>`collabel'</th><th></th></tr>" _n
	// write second row
	file write `handle' "<tr><th></th><th></th>"
	forvalues i=1/`ncolvals' {
		file write `handle' "<th class='subhead'>`colname`i''</th>"
	}
	file write `handle' "<th class='subhead'>Total</th></tr>" _n
	// write third row, including row label down first (merged cells) column
	file write `handle' "<tr><th rowspan='`nrowvals''>`rowlabel'</th>"
	file write `handle' "<th>`rowname1'</th>"
	forvalues i=1/`ncolvals' {
		local thiscount=`matrixname'[1,`i']
		file write `handle' "<td>`thiscount'"
		if "`row'"=="row" | "`col'"=="col" {
			local thisperc : display %3.`dp'f percs[1,`i']
			file write `handle' "<br>`thisperc'&#37;"
		}
		file write `handle' "</td>"
	}
	file write `handle' "<th>`rowtotal1'"
	if "`row'"=="row" {
		file write `handle' "<br>100&#37;"
	}
	file write `handle' "</th></tr>" _n
	// write subsequent rows
	forvalues i=2/`nrowvals' {
		file write `handle' "<tr><th>`rowname`i''</th>"
		forvalues j=1/`ncolvals' {
			local thiscount=`matrixname'[`i',`j']
			file write `handle' "<td>`thiscount'"
			if "`row'"=="row" | "`col'"=="col" {
				local thisperc : display %3.`dp'f percs[`i',`j']
				file write `handle' "<br>`thisperc'&#37;"
			}
			file write `handle' "</td>"
		}
		file write `handle' "<th>`rowtotal`i''"
		if "`row'"=="row" {
			file write `handle' "<br>100&#37;"
		}
		file write `handle' "</th></tr>" _n
	}
	// write final margin
	file write `handle' "<tr><th></th><th>Total</th>"
	forvalues j=1/`ncolvals' {
		file write `handle' "<th>`coltotal`j''"
		if "`col'"=="col" {
			file write `handle' "<br>100&#37;"
		}
		file write `handle' "</th>"
	}
	file write `handle' "<th></th></tr>" _n
	file write `handle' "</table>" _n _n
end



// insert heading text
capture program drop html_h
program define html_h
	syntax , TEXT(string) [Level(integer 2) Handle(string)]
	// defaults
	if "`handle'"=="" {
		local handle "con"
	}
	file write `handle' "<h`level'>`text'</h`level'>" _n
end


// insert image
capture program drop html_img
program define html_img, rclass
	syntax , Img_file(string) [Width(integer 560) Caption(string) Figureno(integer 1) Handle(string)]
	// defaults
	if "`handle'"=="" {
		local handle "con"
	}
	file write `handle' "<p class='caption'>Figure `figureno': `caption'</p>" _n
	file write `handle' "<img src='`img_file'' width='`width'px'>" _n _n
	local ++figureno
	return scalar figureno=`figureno'
end


// insert paragraph
capture program drop html_p
program define html_p
	syntax , TEXT(string) [Caption COLor(string) Strong Em Handle(string) Blocking(string)]
	// defaults
	if "`handle'"=="" {
		local handle "con"
	}
	if "`color'"=="" {
		local color "black"
	}
	// define tags to be pasted together
	if "`strong'"=="strong" {
		local strongtag "<strong>"
		local strongend "</strong>"
	}
	if "`em'"=="em" {
		local emtag "<em>"
		local emend "</em>"
	}
	if "`caption'"=="caption" {
		local captionclass " class='caption' "
	}
	if "`blocking'"!="" {
		local blockcode `"<a href='' onclick="blocking('`blocking''); return false;">"'
		// you need to add </a> yourself...
	}
	local colstyle " style='color:`color';' "
	#delimit ;
	file write `handle' `"<p`colstyle'`captionclass'>`strongtag'`emtag'`blockcode'`text'
						`emend'`strongend'</p>"' _n;
	#delimit cr
end

// insert list
capture program drop html_list
program define html_list
	syntax , TEXT(string) [Unordered Ordered Start End Handle(string)]
	// defaults
	if "`handle'"=="" {
		local handle "con"
	}
	if "`start'"=="start" & "`unordered'"=="unordered" {
		file write `handle' "<ul><li>`text'</li>" _n
	}
	else if "`start'"=="start" & "`ordered'"=="ordered" {
		file write `handle' "<ol><li>`text'</li>" _n
	}
	else if "`start'"=="" & "`end'"=="" {
		file write `handle' "<li>`text'</li>" _n
	}
	else if "`end'"=="end" & "`unordered'"=="unordered" {
		file write `handle' "<li>`text'</li></ul>" _n
	}
	else if "`end'"=="end" & "`ordered'"=="ordered" {
		file write `handle' "<li>`text'</li></ol>" _n
	}
end


// add </a> to end a block of show/hide content
capture program drop html_blockend
program define html_blockend
	syntax [, Handle(string)]
	if "`handle'"=="" {
		local handle "con"
	}
	file write `handle' "</a>" _n
end


// end the HTML file (you still have to close the file connection)
capture program drop html_end
program define html_end
	syntax [, Handle(string)]
	if "`handle'"=="" {
		local handle "con"
	}
	file write `handle' "</body></html>" _n
end


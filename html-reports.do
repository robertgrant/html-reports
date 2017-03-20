/*
	Stata commands for writing output to HTML reports
	Robert Grant, 2015-16
	robertgrantstats.co.uk and github.com/robertgrant
	This work is licensed under a Creative Commons Attribution 4.0 International License: 
	creativecommons.org/licenses/by/4.0/
*/

/* To do:
	all functions except start: include id option
	unitab: Include row label for missing string values and a % non-missing column
	multitab: % of responses (already there), % of all observations (to add)
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
	file write `handle' _tab "}" _n
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
	syntax varlist(min=2 max=2), [Matrixname(string) Row Col Handle(string) Tableno(integer 1)]
	if "`matrixname'"=="" {
		local matrixname "mymat"
	}
	if "`row'"!="" & "`col'"!="" {
		dis as error "Warning: you specified both row and column percentages but only one is permitted."
		dis as error "Outputting row percentages..."
	}
	qui tab `varlist', matcell(`matrixname') matrow(`matrixname') matcol(`matrixname')
	
	
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



// add </a> to end a block of show/hide content
capture program drop html_blockend
program define html_blockend
	syntax [, Handle(string)]
	if "`handle'"=="" {
		local handle "con"
	}
	file write `handle' "</a>" _n
end


/*
	to be added:
	unitab and multitab option to align numbers (centre as default)
	write crosstab
	write table of descriptive stats, given the data
	return unitab and multitab tables as data frames
*/

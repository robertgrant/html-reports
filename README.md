# Simple functions for HTML statistical reports

This project is released under The Unlicense. You can do whatever you want with it.

##R functions

**html_start** writes head information including CSS (of my own choosing, but basically who doesn't like clean simple Helvetica and look-alikes). The Boolean argument *auto_h1* determines whether or not a header is written at the top of the visible content containing the *projecttitle*.

**html_unitab** makes a table describing one categorical variable. You can choose to include or exclude missing data with the Boolean argument include_missing.

**html_multitab** makes a table for a series of dichotomous variables (which must be coded 0 and 1), supplied as columns of a data frame or matrix with suitable colnames.

**html_anytab** takes a matrix or data frame and turns it into a table. Rownames and colnames populate the first column and the header row respectively. Whatever is in the matrix/data frame gets written, so do your formatting in R first. The usual *tableno*, *caption* and *handle* arguments are used.

All the table functions above write a caption with a table number (default 1) and return an integer which is the next table number, so it makes sense to feed this into the next function call, and so on.

**html_p** writes text in a paragraph tag. Boolean arguments *strong*, *em*, *caption* determine the look of it while *col* receives text to write into the color style, so here you can use CSS names, CSS rgb function or hex names.

**html_h** writes a heading; the *level* argument determines whether it's h1, h2, etc.; the default is 2.

**html_img** writes a link to a image file. Default width is 560, and like unitab and multitab, you can specify a caption, and it returns the next *figureno*.

Note that throughout these, the default file *handle* is 'con', so if you call it that, you can just omit the argument.

### Infrequently asked questions

Q: Help, you haven't told me enough about it

A: Read the code, sucka! You'll find the options clear enough to follow in the .R and .do files.

Q: Why don't you add X?

A: The to-do list includes cross-tabulations and tables of descriptive stats given data. Interactive graphics and other JavaScript content is not really the goal here, though it could be bridged in from functions like R2leaflet without too much difficulty. If you want something else, fork it (but attempt nothing without the gloves).

Q: Will this ever get made into a package?

A: Maybe, but I don't feel any need to do that right now. It's made for my own use and if you find it useful too, great. Proper documentation would be a faff and people would keep asking for control over the CSS etc, which is best done to personal taste. It's pretty easy to just source() it in. But be my guest if you want to take that on.

Q: It's OK, but I like my outputs to have X

A: Good. Edit the code to get X. You can keep it, share it, pretend that you wrote it, whatever. That's what it's for. In conversation with Stata-to-HTML-writing supremo Ben Jann, we both felt that *everyone should write their own HTML reporting program*. Seriously. But you can use this as a springboard to get going.

## Stata commands

You should open the file connection first, probably like this: `file open con using "myoutput.html", write text replace`. Notice that I call the file handle `con`. This is fairly common, and it's the default for all the commands that follow, so calling it con at the beginning means never having to specify it afterwards.

**html_start** writes out all the header HTML and CSS you need. Remember that the look you get can be tweaked by changing html-reports.do to the CSS of your liking. You probably want to specify the option `projecttitle(string)` or `no_h1`, otherwise you'll get a h1 heading at the top with the default name "My Project", which will look a bit silly, even if it is your project.

**html_unitab myvar** makes a univariate frequency table of myvar. There is an option `tableno(integer)`, which is 1 by default. This is used in all the table-writing commands. I suggest you create a macro at the outset for your table numbering: `global tabn 1`, then include it like this so it increments:
    html_unitab myvar, tableno($tabn)
    global ++tabn

**html_multitab varlist** expects varlist to be a bunch of binary indicator variables, such as you get from the `tab1 ... , gen()` option.

**html_xtab** makes a crosstab. This is a hell of a lot harder than it seems at first.

**html_h, text("Check this out!") level(2)** will insert a heading in HTML (h2 in this case, because of the level option).

**html_img, img_file(mygraph.png) figureno($fign) caption("Data can be seen to be on the left and the right")** will insert an image file with the desired caption. Note the figureno() option which mirrors the tableno one.

**html_p, text("We then ran some really clever analyses.") color(#4682b4)** will insert a paragraph with the desired text, coloured steelblue. Any color specification is written straight into CSS; it doesn't have to be understood by Stata. There's also a `strong` option for bold type, and `em` for italix. If you look closely at the code, you'll see a `blocking` option which allows you to have paragraphs that get expanded and collapsed to save space. You need to name the blocks and include that in html_start too though. Let's leave that for the more confident coder.

**html_list, ordered text("the first thing I want to say is this") start** will start an ordered (numbered) list. Then, continue with simpler: `html_list, text("and another thing is this")`, before ending thus: `html_list, text(and finally, this") end`.

**html_end** when you're done. Don't forget to close the file connection.

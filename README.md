# Simple functions for HTML statistical reports

##R functions

**html_start** writes head information including CSS (of my own choosing, but basically who doesn't like clean simple Helvetica and look-alikes). The Boolean argument *auto_h1* determines whether or not a header is written at the top of the visible content containing the *projecttitle*.

**html_unitab** makes a table describing one categorical variable. You can choose to include or exclude missing data with the Boolean argument include_missing.

**html_multitab** makes a table for a series of dichotomous variables (which must be coded 0 and 1), supplied as columns of a data frame or matrix with suitable colnames.

**html_anytab** takes a matrix or data frame and turns it into a table. Rownames and colnames populate the first column and the header row respectively. Whatever is in the matrix/data frame gets written, so do your formatting in R first. The usual tableno, caption and handle arguments are used.

Both the table functions write a caption with a table number (default 1) and return an integer which is the next table number, so it makes sense to feed this into the next function call, and so on.

**html_p** writes text in a paragraph tag. Boolean arguments *strong*, *em*, *caption* determine the look of it while *col* receives text to write into the color style, so here you can use CSS names, CSS rgb function or hex names.

**html_h** writes a heading; the *level* argument determines whether it's h1, h2, etc.; the default is 2.

**html_img** writes a link to a image file. Default width is 560, and like unitab and multitab, you can specify a caption, and it returns the next *figureno*.

### Infrequently asked questions

Q: Help, you haven't told me enough about it
A: Read the code, sucka!

Q: I think you should add X
A: The to-do list includes cross-tabulations and tables of descriptive stats given data. Interactive graphics and other JavaScript content is not really the goal here, though it could be bridged in from functions like R2leaflet without too much difficulty.

Q: Will this ever get made into a package?
A: Maybe, but I don't feel any need to do that right now. It's made for my own use and if you find it useful too, great. Proper documentation would be a faff and people would keep asking for control over the CSS etc, which is best done to personal taste. It's pretty easy to just source() it in. But be my guest if you want to take that on.

## Stata commands

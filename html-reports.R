# HTML file start function
html_start<-function(projecttitle='My project',handle=con,auto_h1=TRUE) {
  write("<!DOCTYPE html>",file=handle)
  write("<html>",file=handle)
  write("<head>",file=handle)
  write("<meta name='description' content='R output written to HTML using the html-reports functions by Robert Grant (github.com/robertgrant/html-reports)'>",file=handle)
  write(paste0("<title>",projecttitle,"</title>"),file=handle)
  write("<style>",file=handle)
  write("   body {",file=handle)
  write("      max-width: 900px;",file=handle)
  write("   }",file=handle)
  write("   h1, h2, h3, p, ol, ul {",file=handle)
  write("      font-family: 'Helvetica';",file=handle)
  write("   }",file=handle)
  write("   p.caption {",file=handle)
  write("      font-size: 75%;",file=handle)
  write("      font-style: italic;",file=handle)
  write("   }",file=handle)
  write("   table, th {",file=handle)
  write("      border-bottom: 1px solid black;",file=handle)
  write("      border-top: 1px solid black;",file=handle)
  write("      border-collapse: collapse;",file=handle)
  write("      font-family: 'Helvetica';",file=handle)
  write("   }",file=handle)
  write("   td, tr {",file=handle)
  write("      border-collapse: collapse;",file=handle)
  write("      padding-left: 15px;",file=handle)
  write("      padding-right: 15px;",file=handle)
  write("      padding-top: 5px;",file=handle)
  write("      padding-bottom: 5px;",file=handle)
  write("      font-family: 'Helvetica';",file=handle)
  write("   }",file=handle)
  write("   tr:nth-child(even) {",file=handle)
  write("      background-color: #f2f2f2;",file=handle)
  write("   }",file=handle)
  write("</style>",file=handle)
  write("</head>",file=handle)
  write("<body>",file=handle)
  if(auto_h1) {
    write(paste0("<h1>",projecttitle,"</h1>"),file=handle)
  }
}





# univariate HTML table function
html_unitab<-function(x,handle=con,caption="",tableno=1,include_missing=TRUE) {
  unitab_nonmissing<-table(x,useNA='no')
  unitab<-table(x,useNA='ifany')
  unitab_rows<-length(unitab)
  unitab_rows_nonmissing<-length(unitab_nonmissing)
  unitab_total<-sum(unitab)
  unitab_total_nonmissing<-sum(unitab_nonmissing)
  unitab_perc<-round(100*unitab/unitab_total,0.1)
  unitab_perc_nonmissing<-round(100*unitab_nonmissing/unitab_total_nonmissing,0.1)
  # caption
  write(paste0("<p class='caption'>Table ",tableno,": ",caption,"</p>"),file=handle,append=TRUE)
  # increment table number
  nexttableno<-tableno+1
  # write header row
  if(include_missing) {
    write(paste0("<table><tr><th></th><th>n</th><th>% <br>(N=",
                 unitab_total,
                 ")</th><th>% non-missing <br>(N=",
                 unitab_total_nonmissing,
                 ")</th></tr>"),
          file=handle,append=TRUE)
  }
  else {
    write(paste0("<table><tr><th></th><th>n</th><th>% <br>(N=",
                 unitab_total,
                 ")</th></tr>"),
          file=handle,append=TRUE)
  }

  # write each row
  if(include_missing) {
    for(i in 1:unitab_rows) {
      if(is.na(names(unitab)[i])) {
        write(paste0("<tr><td>Missing",
                     "</td><td>",unitab[i],
                     "</td><td>",unitab_perc[i],"%",
                     "</td><td> -- </td></tr>"),
              file=handle,append=TRUE)
      }
      else {
        write(paste0("<tr><td>",names(unitab)[i],
                     "</td><td>",unitab[i],
                     "</td><td>",unitab_perc[i],"%",
                     "</td><td>",unitab_perc_nonmissing[i],"%</td></tr>"),
              file=handle,append=TRUE)
      }
    }
    # total row
    #write(paste0("<tr><td></td><td>",unitab_total,"</td><td></td><td></td></tr>"),
    #      file=handle,append=TRUE)
    write("</table>",file=handle,append=TRUE)
  }
  else {
    for(i in 1:unitab_rows_nonmissing) {
      write(paste0("<tr><td>",names(unitab)[i],
                   "</td><td>",unitab[i],
                   "</td><td>",unitab_perc[i],"%</td></tr>"),
            file=handle,append=TRUE)
    }
    # total row
    #write(paste0("<tr><td></td><td>",unitab_total,"</td><td></td></tr>"),
    #      file=handle,append=TRUE)
    write("</table>",file=handle,append=TRUE)
  }
  return(nexttableno)
}




# this function makes a multivariate frequency table, with one row for
# each binary 0/1-coded variable, in HTML
# x is a data frame or matrix with sensible colnames
html_multitab<-function(x,handle=con,caption="",tableno=1,include_missing=TRUE) {
  if(any(!(x==1 | x==0 | is.na(x)))) {
    warning('The data provided to html_multitab contains values other than NA, 0 and 1')
  }
  multitab_denom<-apply(x,2,function(x){ sum(!is.na(x)) })
  multitab_num<-apply(x,2,sum)
  multitab_perc<-round(100*multitab_num/multitab_denom,0.1)
  # caption
  write(paste0("<p class='caption'>Table ",tableno,": ",caption,"</p>"),file=handle,append=TRUE)
  # increment table number
  nexttableno<-tableno+1
  # write header row
  write("<table><tr><th></th><th>n</th><th>%</th></tr>",file=handle,append=TRUE)
  # write each row
  for(i in 1:(dim(x)[2])) {
    write(paste0("<tr><td>",colnames(x)[i],
                 "</td><td>",multitab_num[i]," / ",multitab_denom[i],
                 "</td><td>",multitab_perc[i],"%</td></tr>"),
          file=handle,append=TRUE)
  }
  write("</table>",file=handle,append=TRUE)
  return(nexttableno)
}



html_h<-function(text="",level=2,handle=con) {
  write(paste0("<h",level,">",text,"</h",level,">"),file=handle)
}

html_img<-function(img_file,width=560,caption="",figureno=1,handle=con) {
  write(paste0("<p class='caption'>Figure ",figureno,": ",caption,"</p>"),file=handle,append=TRUE)
  write(paste0("<img src='",img_file,"' width='",width,"px'>"),file=handle)
  figureno<-figureno+1
  return(figureno)
}

html_p<-function(text="",caption=FALSE,col="black",strong=FALSE,em=FALSE,handle=con) {
  strongtag<-emtag<-strongend<-emend<-colstyle<-captionclass<-""
  if(strong) {
    strongtag<-"<strong>"
    strongend<-"</strong>"
  }
  if(em) {
    emtag<-"<em>"
    emend<-"</em>"
  }
  if(caption) {
    captionclass<-" class='caption' "
  }
  colstyle<-paste0(" style='color:",col,";' ")
  write(paste0("<p",colstyle,captionclass,">",strongtag,emtag,text,emend,strongend,"</p>"),file=handle)
}

html_anytab<-function(x,handle=con,caption="",tableno=1) {
  # caption
  write(paste0("<p class='caption'>Table ",tableno,": ",caption,"</p>"),file=handle,append=TRUE)
  # increment table number
  nexttableno<-tableno+1
  # write header row
  write("<table><tr><th></th>",file=handle,append=TRUE)
  for(j in 1:(dim(x)[2])) {
    write(paste0("<th>",colnames(x)[j],"</th>"),file=handle,append=TRUE)
  }
  write("</tr>",file=handle,append=TRUE)
  # write each row
  for(i in 1:(dim(x)[1])) {
    write(paste0("<tr><td>",rownames(x)[i],"</td>"),file=handle,append=TRUE)
    for(j in 1:(dim(x)[2])) {
      write(paste0("<td>",x[i,j],"</td>"),file=handle,append=TRUE)
    }
    write("</tr>",file=handle,append=TRUE)
  }
  write("</table>",file=handle,append=TRUE)
  return(nexttableno)
}

# to be added:
# unitab and multitab option to align numbers (centre as default)
# write crosstab
# write table of descriptive stats, given the data
# return unitab and multitab tables as data frames

[![Project Status: Abandoned – Initial development has started, but there has not yet been a stable, usable release; the project has been abandoned and the author(s) do not intend on continuing development.](http://www.repostatus.org/badges/latest/abandoned.svg)](http://www.repostatus.org/#abandoned)

[![Build Status](https://travis-ci.org/ropenscilabs/gdoc.svg?branch=master)](https://travis-ci.org/ropenscilabs/gdoc)
[![Build status](https://ci.appveyor.com/api/projects/status/cufx3eldk041fs8t?svg=true)](https://ci.appveyor.com/project/NoamRoss/gdoc)


# gdoc

This package contains an R Markdown template for compiling and uploading `.Rmd`
files to Google Docs.  It is an experiment produced at the
[ROpenSci 2016 Unconf](https://github.com/ropensci/unconf16/issues/9).

## Install

    devtools::install_github('ropenscilabs/gdoc')
    
## Use

The `gtemplate()` function will create a test document with default name
`test.Rmd`.

    my_rmd = gtemplate()
    
Render your file:

    rmarkdown::render(my_rmd)
    
Or, for any file:
    
    library(gdoc)
    rmarkdown::render(my_rmd, output_format=gdoc())
    
If you want to use the RStudio "Knit" button to render, you'll have to
pre-authenticate with Google Docs before knitting, like so:

    `gd_auth()`

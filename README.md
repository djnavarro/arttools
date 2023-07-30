
# arttools

<!-- badges: start -->
[![R-CMD-check](https://github.com/djnavarro/arttools/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/djnavarro/arttools/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

This is a personal package used to help with my generative art workflows. It's not a package to help write the code for generative art systems: rather, it's a package I use to make it easier to maintain the source code for the generative art system, the output files created by running the code, and to organise images into a format suitable for publishing to the web. 

The reason for writing something like this is that if you've been making generative art for a long time (and don't have any tools to help manage the workflow) you find that you've ended up with hundreds of art systems with no standardisation and no consistent structure, and as a consequence you can easily end up with tens of thousands of images with no organisation to them at all. That makes it very difficult to keep track of what you've created, and even harder to create a portfolio website that shows off your lovely creations to the world. 

The arttools package is my attempt to organise my own art workflows. I'm trying to write in a fashion that is reasonably portable (so other people might in theory be able to use it), but for the moment my goal is modest: for the time being I'm aiming to systematise my own art workflows, that's all.

Since this is a personal package it's not on CRAN and likely never will be but on the off chance someone else wants to tinker with it, the package can be installed from github with:

``` r
remotes::install_github("djnavarro/arttools")
```




<!-- README.md is generated from README.Rmd. Please edit that file -->
worktime
========

The goal of worktime is to visualize time spent working. Can also import clocking data from `.org` files.

Installation
============

``` r
# install.packages("devtools")
devtools::install_github("lwjohnst86/worktime")
```

Usage
=====

Have an `.org` file where you clock your time? Import it into R so you can do data analysis on your hours!

``` r
library(worktime)
library(dplyr)
clocking <- import_org_clock("data-raw/clocking.org")
clocking
#> # A tibble: 3,083 x 6
#>    Header1 Header2 Header3 Header4 ClockIn             ClockOut           
#>    <chr>   <chr>   <chr>   <chr>   <dttm>              <dttm>             
#>  1 " Orga… <NA>    <NA>    <NA>    2017-09-21 11:58:00 2017-09-21 12:27:00
#>  2 " Orga… <NA>    <NA>    <NA>    2017-09-21 11:45:00 2017-09-21 11:52:00
#>  3 " Orga… <NA>    <NA>    <NA>    2017-09-20 17:44:00 2017-09-20 17:54:00
#>  4 " Orga… <NA>    <NA>    <NA>    2017-09-20 17:43:00 2017-09-20 17:44:00
#>  5 " Orga… <NA>    <NA>    <NA>    2017-09-20 12:58:00 2017-09-20 13:16:00
#>  6 " Orga… <NA>    <NA>    <NA>    2017-09-20 12:08:00 2017-09-20 12:38:00
#>  7 " Orga… <NA>    <NA>    <NA>    2017-09-19 17:17:00 2017-09-19 17:28:00
#>  8 " Orga… <NA>    <NA>    <NA>    2017-09-19 11:48:00 2017-09-19 11:51:00
#>  9 " Orga… <NA>    <NA>    <NA>    2017-09-18 12:11:00 2017-09-18 12:21:00
#> 10 " Orga… <NA>    <NA>    <NA>    2017-09-18 11:55:00 2017-09-18 12:07:00
#> # ... with 3,073 more rows
```

Check how much time you've spent on each task/heading.

``` r
clocking %>% 
    add_minutes_worked() %>% 
    group_by(Header1) %>% 
    summarize(TotalHoursWorked = sum(as.numeric(MinutesWorked)) / 60)
#> # A tibble: 6 x 2
#>   Header1         TotalHoursWorked
#>   <chr>                      <dbl>
#> 1 " Learning"                 21.1
#> 2 " Misc"                    148  
#> 3 " Organization"            269  
#> 4 " Programming"             105  
#> 5 " Research"                619  
#> 6 " Teaching"                144
```

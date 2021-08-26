The Benford Law (`BenfordLaw`) package provides basic tools in order to confirm compliance of a data to Benford Law. The main purpose of the package is to have a basic understanding of Benford Law and to easily apply it.

Example usage
-------------

The `BenfordLaw` package comes with the "U.S President" dataset. This latter can be found at the [MIT Election Data Science Lab website](https://electionlab.mit.edu/data). It contains contains US presidential election data from 1976 to 2020 by county.

Here we will give an example using the whole dataset (4,287 observations) from the election data. The first step will be to load the package and to import the data.

``` r
library(BenfordLaw) # loads package 

# loads other library needed
library(tidyverse)
#> ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.1 ──
#> ✓ ggplot2 3.3.5     ✓ purrr   0.3.4
#> ✓ tibble  3.1.3     ✓ dplyr   1.0.7
#> ✓ tidyr   1.1.3     ✓ stringr 1.4.0
#> ✓ readr   1.4.0     ✓ forcats 0.5.1
#> ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
#> x dplyr::filter() masks stats::filter()
#> x dplyr::lag()    masks stats::lag()
library(ggpubr) # ggarrange
library(naniar) # replace_with_na_all()
library(data.table)
#> 
#> Attaching package: 'data.table'
#> The following objects are masked from 'package:dplyr':
#> 
#>     between, first, last
#> The following object is masked from 'package:purrr':
#> 
#>     transpose
library(stats)

 # loads data
raw2 = read.csv("data/countypres_2000-2020.csv",
               na.strings=c("","NA"))

# convert to tibble
data2 = raw2 %>%
  as_tibble()
```

When your data is loaded, select the column with the numbers that you want to analyze. Then the function will automatically print all the statistics that you need. The default digit is "1".

``` r
# first digit analysis
first = data2 %>% 
  select(candidatevotes) %>%
  benfordfct()

first
#> $chi2
#>    observed.prop observed.N lower_bound upper_bound theory x.squared.prop
#> 1:             1     0.2854      0.2977      0.3044 0.3010              1
#> 2:             2     0.1713      0.1733      0.1789 0.1761              2
#> 3:             3     0.1236      0.1225      0.1274 0.1249              3
#> 4:             4     0.0964      0.0948      0.0991 0.0969              4
#> 5:             5     0.0784      0.0772      0.0812 0.0792              5
#> 6:             6     0.0635      0.0651      0.0688 0.0669              6
#> 7:             7     0.0540      0.0563      0.0597 0.0580              7
#> 8:             8     0.0477      0.0496      0.0528 0.0512              8
#> 9:             9     0.0427      0.0442      0.0473 0.0458              9
#>     x.squared.N    chisq df pvalue
#> 1: 8.085243e-04 134.5289  8      0
#> 2: 1.305841e-04 134.5289  8      0
#> 3: 1.448119e-05 134.5289  8      0
#> 4: 2.580553e-06 134.5289  8      0
#> 5: 8.030200e-06 134.5289  8      0
#> 6: 1.819969e-04 134.5289  8      0
#> 7: 2.734991e-04 134.5289  8      0
#> 8: 2.327126e-04 134.5289  8      0
#> 9: 2.001726e-04 134.5289  8      0
#> 
#> $sumsd
#> $sumsd$ssd
#> [1] 3.181881
#> 
#> 
#> $zstat
#>    z.prop    z.N
#> 1:      1 9.1610
#> 2:      2 3.3877
#> 3:      3 1.0906
#> 4:      4 0.4493
#> 5:      5 0.7889
#> 6:      6 3.7561
#> 7:      7 4.5837
#> 8:      8 4.2118
#> 9:      9 3.8941
```

It shows the lower bound and upper bound of the expected proportion with the expected benford proportion itself. Then, the chisquare value, critical value, df and p-value. Just below it shows the ssd value. Finally it computes the zstat values for each digit.

You can choose to only print the stat that you need. For example here below the uniquely the chi2 critical value.

``` r
# first digit chi2 critical value
first$chi2$chisq
#> [1] 134.5289 134.5289 134.5289 134.5289 134.5289 134.5289 134.5289 134.5289
#> [9] 134.5289
```

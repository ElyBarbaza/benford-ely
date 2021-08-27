#### Package benford.ely ####

##' Benford Ely for benford introduction and example analytics
##'
##' The Benford Ely package provides an easy function to compute
##' all the basic summary and statistics that you need to perform
##' an analysis at your data with regard to Benford Law.
##' And then identify data that could have been manipulated and which
##' will need further verification.
##'
##' More information can be found on its help documentation.
##'
##' The main and only function is \code{\link{benfordfct}}.
##'
##' The package prints confidence intervals, chi2 stats, z and ssd values.
##'
##'
##' The package also includes a complete study analysing the US 2020 elections
##'
##' ##' @examples
##' benfordfct(data,digit) # generates all the statistics mentionned above
##' data is a column dataset number
##' digit is by default 1
##' digit is an integer that can be in the interval [1:9] which represent its digit
##' and digit can be "12" which represent first-two digits


# benford function
# description

#' @title Benford function
#' @description It gets all the summary and statistics for a dataset.
#' \code{\link{benford}}.
#' @usage
#'
#' benfordfct(data,digit)
#' @param data one column dataset with type integer.
#' @param digit number within this interval [1;9] & "12"
#' @return A list with confidence interval, chi2 stats, ssd & zstat
#' @examples
#' data(data) #gets data
#' benfordfct(data)
#' @export

benfordfct = function(data,digit=1){

  # compute theory proportion
  if (digit < 10) {
    if (digit > 1 & digit < 10){ # if digit == 2
      theory_prop = c()
      for (i in 0:9){
        theory_prop = c(theory_prop,sum(log10(1+1/((10*(10^(digit-2)):((10^(digit-1))-1))+i))))
      }
    } else if (digit == 1){ # if digit = 1
      data = data %>%
        replace_with_na_all(condition = ~.x %in% 0) # replacd to NA all 0's
      theory_prop = log10(1 + 1/(1:9))
    }

    # compute observed proportion
    prop = as.vector(t(data))
    prop = as.numeric(substr(prop, 1, digit)) %% 10 # extracting digits
    prop = table(prop)

  } else if (digit == 12){
    # first,two digits
    theory_prop = log10(1+1/(10:99))

    prop = as.vector(t(data))
    prop = as.numeric(substr(prop, 1, 2)) %% 100 # digits
    prop = table(prop)

  }
  else {
    stop("Wrong digit")
  }


  len = nrow(data)

  # compute chisq test
  observed = prop/len
  theory = theory_prop
  x.squared = ((observed - theory)^2)/theory
  chisq = len * sum(x.squared)
  df = length(x.squared) - 1
  pvalue = pchisq(chisq, df, lower.tail = FALSE)

  # compute ssd test
  ssd = sum(((100)*observed - (100) * theory)^2)

  # compute z-statistic
  z = ((abs(observed - theory) - (1/(2*len))))/sqrt((theory*(1-theory))/len)

  # compute confidence intervals for each digit
  # We choose alpha = 0.05 thus :
  zalpha = qnorm(0.025,lower.tail = FALSE)
  lower_b = theory - zalpha * ((theory * (1-theory)/len))^0.5 + 1/(2*len)
  upper_b = theory + zalpha * ((theory * (1-theory)/len))^0.5 + 1/(2*len)

  # compute final output
  output = list(chi2 = data.table(observed = round(observed,digits = 4),
                                  lower_bound = round(lower_b,digits = 4),
                                  upper_bound = round(upper_b,digits = 4),
                                  theory = round(theory_prop,digits = 4),
                                  x.squared = x.squared,
                                  chisq = round(chisq,digits = 4),
                                  df = df,
                                  pvalue = round(pvalue,digits = 4)),

                sumsd = list(ssd = ssd),

                zstat = data.table(z = round(z,digits = 4))


  )

  return(output)
}




# benford function

# FUNCTION ----------------------------------------------------------------
benfordfct = function(data,digit=1){
  # compute theory proportion
  if (digit > 1 & digit < 5){
    theory_prop = c()
    for (i in 0:9){
      theory_prop = c(theory_prop,sum(log10(1+1/((10*(10^(digit-2)):((10^(digit-1))-1))+i))))
    }
  } else if (digit == 1){
    data = data %>%
      replace_with_na_all(condition = ~.x %in% 0)
    theory_prop = log10(1 + 1/(1:9))
  }
  else {
    return("Wrong digit")
  }


  # compute data proportion
  prop = as.vector(t(data))
  prop = as.numeric(substr(prop, 1, digit)) %% 10 # digits
  prop = table(prop)
  #prop = c(0,prop)
  #prop = prop/sum(prop)

  # compute adequation test (chi2)
  print(paste0("Mean: ",mean(prop)))


  stat = chisq.test(prop,p=theory_prop)

  return(stat)
}

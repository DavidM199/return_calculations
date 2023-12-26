library(pdfetch)
library(tidyr)
library(dplyr)

#setting up the environment
ETF_top20 <- read_csv("ETF_top20.csv")
etf_vector <- ETF_top20[["composite_ticker"]]

#retrieving data from 2020-01-01 to 2022-12-31 (2020-2023)
adjcloses <- pdfetch_YAHOO(etf_vector, "adjclose", from = "2020-01-01", to = "2022-12-31") %>% as.data.frame()
ETF_date_pairs <- cbind(date = rownames(adjcloses), adjcloses) %>% gather("ETF", "adjclose", 2:21)

#separated the data by ETF, for easier navigation
list_of_dataframes <- split(ETF_date_pairs, ETF_date_pairs$ETF)  

#adding the individual columns for the returns 
days <- 20
list_of_dataframes <- lapply(list_of_dataframes, function(df.etf) {
  
  for (i in 1:days){
    df.etf <- df.etf %>% 
      mutate("etf_ret_d_{i}" := lead((adjclose - lag(adjclose)) / lag(adjclose) , n = i ) )
  }
  
  return(df.etf)
  
})


final_df <- bind_rows(list_of_dataframes)
write.csv(final_df, file = "final_df.csv")

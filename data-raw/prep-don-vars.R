library("tidyverse")
library("sf")

don = readRDS("data/don.rds")
vars = readRDS("data/vars.rds")

don =
  don %>%
  select(-`Prisoner population`) %>%
  mutate_if(is.numeric, round)

saveRDS(don, file = "data/don.rds", compress = FALSE)

vars = c(
  don %>%
    st_set_geometry(NULL) %>%
    colnames(.) %>%
    stringr::str_subset(., "[^code]") %>%
    stringr::str_subset(., "[^name]")
)

saveRDS(vars, file = "data/vars.rds", compress = FALSE)


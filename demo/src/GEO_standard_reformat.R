library(tidyverse)
dat <- read_tsv("demo/data/GSE60682_standard.tsv")
dat_t <- t(dat)
columns <- dat_t[1,]
rows <- names(dat_t[,1])
rownames(dat_t) <- rows
colnames(dat_t) <- columns
cbind(rows,dat_t) %>% 
  as.data.frame() %>% 
  write_csv("demo/data/GSE60682_standard_reformat.csv",)

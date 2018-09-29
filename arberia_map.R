#################################################################
# V.1 del codice per creare la mappa dei paesi d'arberia in
# Italia
#################################################################
library(magrittr)

# download del dato da wikipedia
library(rvest)
url <- "https://it.wikipedia.org/wiki/Comuni_dell%27Arberia"
comuni <- url %>%
  read_html() %>%
  html_nodes("table") %>%
  html_table(fill = T)

# preprocessing del dato
library(dplyr)
library(stringr)
comuni.DF <- bind_rows(comuni)
comuni.DF <- comuni.DF[!is.na(comuni.DF$`Nome italiano`),1:4]
comuni.DF$Abitanti <- comuni.DF$Abitanti %>%
  str_remove(pattern = " ab.") %>%
  gsub(pattern = "\\.", replacement = "") %>%
  as.numeric()
comuni.DF$Note <- comuni.DF$Note %>%
  str_remove(pattern = '" "')

# estrazione delle coordinate da OSM
library(ggmap)
comuni.DF <- comuni.DF %>%
  mutate(lat = geocode(comuni.DF$`Nome italiano`, output = "latlon" , source = "dsk")[[2]],
         lon = geocode(comuni.DF$`Nome italiano`, output = "latlon" , source = "dsk")[[1]])

# creazione CSV
write.csv(x = comuni.DF, file = "dati/comuniArberia.csv", row.names = F)

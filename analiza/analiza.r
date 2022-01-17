# 4. faza: Napredna analiza podatkov

library(sp)
library(rgdal)
library(raster)
library(rgeos)
library(tidyverse)
library(cluster)

source("lib/obrisi.r")
source("lib/hc.kolena.R")
source("lib/diagram.obrisi.r")
source("lib/diagram.skupine.R")

################################################################################

# Branje podatkov za napredno analizo

tabela = read_csv(
  "podatki/tabela.csv",
  locale = locale(encoding = "Windows-1250"),
  col_types = cols(
    .default = col_guess(),
    regija = col_factor()
  )
) %>% select(-1)

tabela1 <- tabela %>% mutate(st.poskodovanih.na.10000.preb = stevilo.poskodovanih / prebivalci * 10000, 
                             st.nesrec.na.10000.preb = stevilo.nesrec / prebivalci * 10000, 
                             st.nesrec.na.1000.vozil = stevilo.nesrec / stevilo.vozil * 1000)

tabela1 <- tabela1 %>% 
  filter(regija != "SLOVENIJA", leto == 2019) %>%
  mutate(
    indeks.rasti.nesrec = stevilo.nesrec - lag(stevilo.nesrec), 
    indeks.rasti.poskodovanih = stevilo.poskodovanih - lag(stevilo.poskodovanih)
  ) %>%
  select(regija, st.nesrec.na.10000.preb)

source("lib/uvozi.zemljevid.r")

Slovenija <- uvozi.zemljevid("http://biogeo.ucdavis.edu/data/gadm2.8/shp/SVN_adm_shp.zip",
                             "SVN_adm1", encoding="UTF-8") %>% fortify()
Slovenija$NAME_1 <- gsub('Notranjsko-kraška', 'Primorsko-notranjska', Slovenija$NAME_1)
Slovenija$NAME_1 <- gsub('Spodnjeposavska', 'Posavska', Slovenija$NAME_1)

################################################################################

# Metoda voditeljev

tabela1.norm <- tabela1 %>% select(-regija) %>% scale()
rownames(tabela1.norm) <- tabela1$regija
k <- kmeans(tabela1.norm, 3, nstart = 1000)

head(k$cluster, n=12)
table(k$cluster)

k$tot.withinss

library(tmap)
skupine <- data.frame(regija=tabela1$regija, skupina=factor(k$cluster))
zemljevid <- tm_shape(merge(Slovenija, skupine, by.x="NAME_1", by.y="regija")) + tm_polygons("skupina")
tmap_mode("view")

# 2. faza: Uvoz podatkov

library(tidyverse)
library(readr)
library(stringr)
library(readxl)

sl <- locale("sl", decimal_mark=",", grouping_mark=".")

# Branje podatkov:

prebivalstvo <- read_csv(
  "podatki/regije-prebivalstvo.csv",
  skip = 2,
  col_names = TRUE,
  locale = locale(encoding = "Windows-1250"),
  col_types = cols(
    .default = col_guess(), # zaupaj R-ju tipe vseh stolpcev
    )
  )

vozila <- read_csv(
  "podatki/regije-vozila.csv",
  skip = 2,
  col_names = TRUE,
  locale = locale(encoding = "Windows-1250"),
  col_types = cols(
    .default = col_double(),
    OBČINE = col_character()
    )
  )


nesrece.2015 <- read_excel("podatki/nesrece-2015.xlsx", sheet = "nesrece-2015")

nesrece.2016 <- read_excel("podatki/nesrece-2016.xlsx", sheet = "pn2016")

nesrece.2017 <- read_excel("podatki/nesrece-2017.xlsx", sheet = "nesrece-2017")

nesrece.2018 <- read_excel("podatki/nesrece-2018.xlsx", sheet = "nesrece-2018")

nesrece.2019 <- read_excel("podatki/nesrece-2019.xlsx", sheet = "nesrece-2019")

nesrece.2020 <- read_excel("podatki/nesrece-2020.xlsx", sheet = "nesrece-2020")

nesrece.udelezenci <- read_csv(
  "podatki/regije-nesrece-udelezenci.csv",
  skip = 2,
  col_names = TRUE,
  locale = locale(encoding = "Windows-1250"),
  col_types = cols(
    .default = col_guess(), # zaupaj R-ju tipe vseh stolpcev
    )
  )

nesrece <- read_csv(
  "podatki/regije-nesrece.csv",
  skip = 2,
  col_names = TRUE,
  locale = locale(encoding = "Windows-1250"),
  col_types = cols(
    .default = col_guess(),
    )
  )

obcine.regije <- read_csv(
  "podatki/obcine-regije.csv",
  col_names = TRUE,
  locale = locale(encoding = "utf-8"),
  col_types = cols(
    .default = col_guess(),
    )
  )


# Čiščenje podatkov
# 1. Urejanje pivotnih tabel

prebivalstvo1 <- pivot_longer(prebivalstvo,
                                cols = colnames(prebivalstvo)[-1], # prvi stolpec, ki ustreza regiji pustimo pri miru
                                names_to = "leto", # imena stolpcev naj gredo v nov stolpec "leto"
                                values_to = "prebivalci" # vrednosti naj gredo v nov stolpec "prebivalci"
) %>% rename("regija"="STATISTIČNA REGIJA")

nesrece1 <- pivot_longer(nesrece, 
                         cols = colnames(nesrece)[-1],
                         names_to = "leto.vrsta",
                         values_to = "stevilo"
) %>% rename("regija"="STATISTIČNA REGIJA")

vozila1 <- pivot_longer(vozila,
                        cols = colnames(vozila)[-1],
                        names_to = "leto",
                        values_to = "stevilo-vozil"
) %>% rename("obcina"="OBČINE")

nesrece_udelezenci1 <- pivot_longer(nesrece_udelezenci,
                                   cols = colnames(nesrece_udelezenci)[-1],
                                   names_to = "leto.poskodba",
                                   values_to = "stevilo"
) %>% rename("regija"="STATISTIČNA REGIJA")

nesrece_2015 <- nesrece.2015 %>% select(ZaporednaStevilkaPN, KlasifikacijaNesrece, UpravnaEnotaStoritve) %>%
  rename("stevilka-nesrece"="ZaporednaStevilkaPN", "vrsta"="KlasifikacijaNesrece", "stevilo"="UpravnaEnotaStoritve")
nesrece_2015$leto <- 2015

nesrece_2016 <- nesrece.2016 %>% select(ZaporednaStevilkaPN, KlasifikacijaNesrece, UpravnaEnotaStoritve) %>%
  rename("stevilka-nesrece"="ZaporednaStevilkaPN", "vrsta"="KlasifikacijaNesrece", "stevilo"="UpravnaEnotaStoritve")
nesrece_2016$leto <- 2016

nesrece_2017 <- nesrece.2017 %>% select(ZaporednaStevilkaPN, KlasifikacijaNesrece, UpravnaEnotaStoritve) %>%
  rename("stevilka-nesrece"="ZaporednaStevilkaPN", "vrsta"="KlasifikacijaNesrece", "stevilo"="UpravnaEnotaStoritve")
nesrece_2017$leto <- 2017

nesrece_2018 <- nesrece.2018 %>% select(ZaporednaStevilkaPN, KlasifikacijaNesrece, UpravnaEnotaStoritve) %>%
  rename("stevilka-nesrece"="ZaporednaStevilkaPN", "vrsta"="KlasifikacijaNesrece", "stevilo"="UpravnaEnotaStoritve")
nesrece_2018$leto <- 2018

nesrece_2019 <- nesrece.2019 %>% select(ZaporednaStevilkaPN, KlasifikacijaNesrece, UpravnaEnotaStoritve) %>%
  rename("stevilka-nesrece"="ZaporednaStevilkaPN", "vrsta"="KlasifikacijaNesrece", "stevilo"="UpravnaEnotaStoritve")
nesrece_2019$leto <- 2019

nesrece_2020 <- nesrece.2020 %>% select(ZaporednaStevilkaPN, KlasifikacijaNesrece, UpravnaEnotaStoritve) %>%
  rename("stevilka-nesrece"="ZaporednaStevilkaPN", "vrsta"="KlasifikacijaNesrece", "stevilo"="UpravnaEnotaStoritve")
nesrece_2020$leto <- 2020

nesrece_udelezenci_2015 <- nesrece.2015 %>% select(KlasifikacijaNesrece, UpravnaEnotaStoritve, PoskodbaUdelezenca) %>%
  rename("vrsta"="KlasifikacijaNesrece", "obcina"="UpravnaEnotaStoritve", "poskodba"="PoskodbaUdelezenca")
nesrece_udelezenci_2015$leto <- 2015

nesrece_udelezenci_2016 <- nesrece.2016 %>% select(KlasifikacijaNesrece, UpravnaEnotaStoritve, PoskodbaUdelezenca) %>%
  rename("vrsta"="KlasifikacijaNesrece", "obcina"="UpravnaEnotaStoritve", "poskodba"="PoskodbaUdelezenca")
nesrece_udelezenci_2016$leto <- 2016

nesrece_udelezenci_2017 <- nesrece.2017 %>% select(KlasifikacijaNesrece, UpravnaEnotaStoritve, PoskodbaUdelezenca) %>%
  rename("vrsta"="KlasifikacijaNesrece", "obcina"="UpravnaEnotaStoritve", "poskodba"="PoskodbaUdelezenca")
nesrece_udelezenci_2017$leto <- 2017

nesrece_udelezenci_2018 <- nesrece.2018 %>% select(KlasifikacijaNesrece, UpravnaEnotaStoritve, PoskodbaUdelezenca) %>%
  rename("vrsta"="KlasifikacijaNesrece", "obcina"="UpravnaEnotaStoritve", "poskodba"="PoskodbaUdelezenca")
nesrece_udelezenci_2018$leto <- 2018

nesrece_udelezenci_2019 <- nesrece.2019 %>% select(KlasifikacijaNesrece, UpravnaEnotaStoritve, PoskodbaUdelezenca) %>%
  rename("vrsta"="KlasifikacijaNesrece", "obcina"="UpravnaEnotaStoritve", "poskodba"="PoskodbaUdelezenca")
nesrece_udelezenci_2019$leto <- 2019

nesrece_udelezenci_2020 <- nesrece.2020 %>% select(KlasifikacijaNesrece, UpravnaEnotaStoritve, PoskodbaUdelezenca) %>%
  rename("vrsta"="KlasifikacijaNesrece", "obcina"="UpravnaEnotaStoritve", "poskodba"="PoskodbaUdelezenca")
nesrece_udelezenci_2020$leto <- 2020

















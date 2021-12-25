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
    .default = col_guess(),
    )
  )

nesrece_2015 <- read_excel("podatki/nesrece-2015.xlsx", sheet = "nesrece-2015")

nesrece_2016 <- read_excel("podatki/nesrece-2016.xlsx", sheet = "pn2016")

nesrece_2017 <- read_excel("podatki/nesrece-2017.xlsx", sheet = "nesrece-2017")

nesrece_2018 <- read_excel("podatki/nesrece-2018.xlsx", sheet = "nesrece-2018")

nesrece_2019 <- read_excel("podatki/nesrece-2019.xlsx", sheet = "nesrece-2019")

nesrece_2020 <- read_excel("podatki/nesrece-2020.xlsx", sheet = "nesrece-2020")

nesrece_udelezenci <- read_csv(
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
)

nesrece1 <- pivot_longer(nesrece, 
                         cols = colnames(nesrece)[-1],
                         names_to = "leto.vrsta",
                         values_to = "poskodovani"
)

vozila1 <- pivot_longer(vozila,
                        cols = colnames(vozila)[-1],
                        names_to = "leto",
                        values_to = "stevilo-vozil"
)

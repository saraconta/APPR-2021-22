library(knitr)
library(rvest)
library(gsubfn)
library(tidyr)
library(tmap)
library(shiny)
library(readr)
library(tidyverse)
library(stringr)
library(readxl)
library(ggplot2)
library(sp)
library(rgdal)
library(rgeos)
library(raster)

## test

options(gsubfn.engine="R")

# Uvozimo funkcije za pobiranje in uvoz zemljevida.
source("lib/uvozi.zemljevid.r", encoding="UTF-8")

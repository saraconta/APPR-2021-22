# 3. faza: 
# VIZUALIZACIJA PODATKOV

library(tidyverse)
library(ggplot2)

tabela = read_csv(
  "tabela.csv",
  locale = locale(encoding = "Windows-1250"),
  col_types = cols(
    .default = col_guess(),
    regija = col_factor()
  )
) %>% select(-1)

################################################################################
# Dodajanje novih spremenljivk
#-------------------------------------------------------------------------------

tabela1 <- tabela %>% mutate(st.poskodovanih.na.10000.preb = stevilo.poskodovanih / prebivalci * 10000, 
                             st.nesrec.na.10000.preb = stevilo.nesrec / prebivalci * 10000, 
                             st.nesrec.na.1000.vozil = stevilo.nesrec / stevilo.vozil * 1000)

tabela1 <- tabela1 %>%
  group_by(regija) %>%
  mutate(
    indeks.rasti.nesrec = stevilo.nesrec - lag(stevilo.nesrec), 
    indeks.rasti.poskodovanih = stevilo.poskodovanih - lag(stevilo.poskodovanih)
  )

################################################################################
# Analiza prvega in zadnjega opazovanega leta; število nesreč

prvo.leto <- min(tabela1$leto)
zadnje.leto <- max(tabela$leto)

tabela1.graf1 <- tabela1 %>% filter(leto == prvo.leto)
tabela1.graf2 <- tabela1 %>% filter(leto == zadnje.leto)
#-------------------------------------------------------------------------------

# Graf števila nesreč na 10.000 prebivalcev v letu 2007

ggplot(tabela1.graf1, mapping = aes(x = reorder(regija, -st.nesrec.na.10000.preb), y = st.nesrec.na.10000.preb)) +
  geom_bar(stat = "identity") + 
  xlab("Regija") + ylab("Število nesreč na 10.000 prebivalcev") +
  ggtitle("Nesreče leta 2007") + 
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5)) + 
  tabela1.graf1 %>%
  filter(regija == "SLOVENIJA") %>%
  geom_bar(
    mapping = aes(x = regija, y = st.nesrec.na.10000.preb),
    stat = "identity", 
    fill = "#FF6666"
  )

#-------------------------------------------------------------------------------

# Graf števila nesreč na 10.000 prebivalcev v letu 2020

ggplot(tabela1.graf2, mapping = aes(x = reorder(regija, -st.nesrec.na.10000.preb), y = st.nesrec.na.10000.preb)) +
  geom_bar(stat = "identity") + 
  xlab("Regija") + ylab("Število nesreč na 10.000 prebivalcev") +
  ggtitle("Nesreče leta 2020") + 
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5)) + 
  tabela1.graf2 %>%
  filter(regija == "SLOVENIJA") %>%
  geom_bar(
    mapping = aes(x = regija, y = st.nesrec.na.10000.preb),
    stat = "identity",
    fill = "#FF6666"
  )
#-------------------------------------------------------------------------------

# Graf poškodovanih po letih, ločeno po regijah (brez Slovenije)

tabela1 %>% filter(regija != "SLOVENIJA") %>%
  ggplot(
    mapping = aes(x = leto, y = st.poskodovanih.na.10000.preb, color = regija)
  ) +
  geom_line() +
  theme(
    axis.text.x = element_text(angle = 45, vjust = 0.5),
    legend.position = "bottom"
  ) + 
  xlab("Leto") + ylab("Število") + 
  ggtitle("Poškodovani na 10.000 prebivalcev")
#-------------------------------------------------------------------------------

# Grafi po regijah za število nesreč na 1.000 vozil

ggplot(tabela1) + 
  aes(x = leto, y = st.nesrec.na.1000.vozil) + 
  geom_col() + 
  facet_wrap(. ~ regija)
#-------------------------------------------------------------------------------

# Graf nesrec na vozilo v odvisnosti od nesrec na prebivalca, za regiji mojega doma in regijo fakultete

ggplot(tabela1 %>% filter(regija %in% c("Osrednjeslovenska", "Jugovzhodna Slovenija", "Posavska"))) + 
  aes(x = st.nesrec.na.1000.vozil, y = st.nesrec.na.10000.preb, color = leto, shape = regija) + 
  geom_point()
#-------------------------------------------------------------------------------

# Indeks rasti nesreč za Osrednjeslovensko regijo
ggplot(tabela1 %>% filter(regija == "Osrednjeslovenska") %>% select(leto, indeks.rasti.nesrec)) + 
  aes(x = leto, y = indeks.rasti.nesrec) + 
  geom_line() + 
  xlab("Leto") + ylab("Indeks") + 
  ggtitle("Indeks rasti nesreč za Osrednjeslovensko") + 
  theme_light()

# Indeks rasti nesreč za Slovenijo
ggplot(tabela1 %>% filter(regija == "SLOVENIJA") %>% select(leto, indeks.rasti.nesrec)) + 
  aes(x = leto, y = indeks.rasti.nesrec) + 
  geom_line() + 
  xlab("Leto") + ylab("Indeks") + 
  ggtitle("Indeks rasti nesreč za Slovenijo") + 
  theme_minimal()
#-------------------------------------------------------------------------------

# Graf kvantilov za število nesreč
  
  ggplot(tabela1 %>% mutate(leto = as.character(leto))) + # Dodala mutate, ker leto ni 'character'
  aes(x = leto, y = stevilo.nesrec) + 
  geom_boxplot()
#-------------------------------------------------------------------------------

# Graf kvantilov za število poškodovanih

ggplot(tabela1 %>% mutate(leto = as.character(leto))) + # Dodala mutate, ker leto ni 'character'
  aes(x = leto, y = stevilo.poskodovanih) + 
  geom_boxplot()
#-------------------------------------------------------------------------------

# Graf števila nesreč po letih, barvno ločeno po regijah

tabela1 %>%
  group_by(leto) %>%
  filter(regija != "SLOVENIJA") %>%
  ggplot(
    mapping = aes(x = leto, y = stevilo.nesrec, fill = reorder(regija, prebivalci))
  ) +
  geom_bar(
    stat = "identity",
    position = position_fill()
  )
  
################################################################################ 
# ZEMLJEVIDI

library(sp)
library(rgdal)
library(rgeos)
library(raster)
library(tmap)
#-------------------------------------------------------------------------------

# Zemljevid slovenskih statističnih regij

slo.regije.sp <- readOGR("zemljevidi/si/gadm36_SVN_1.shp")

slo.regije.map <- slo.regije.sp %>% spTransform(CRS("+proj=longlat +datum=WGS84"))

slo.regije.poligoni <- fortify(slo.regije.map)

slo.regije.poligoni <- slo.regije.poligoni %>%
  left_join(
    rownames_to_column(slo.regije.map@data),
    by = c("id" = "rowname")
  ) %>%
  select(
    regija = NAME_1, long, lat, order, hole, piece, id, group
  ) %>%
  mutate(
    regija = replace(regija, regija == "Notranjsko-kraška", "Primorsko-notranjska"),
    regija = replace(regija, regija == "Spodnjeposavska", "Posavska")
  )
slo.regije.poligoni %>% write_csv("zemljevidi/si/regije-poligoni.csv")

slo.regije.centroidi <- slo.regije.map %>% coordinates %>% as.data.frame
colnames(slo.regije.centroidi) <- c("long", "lat")

slo.regije.centroidi <- slo.regije.centroidi %>% rownames_to_column() %>%
  left_join(
    rownames_to_column(slo.regije.map@data),
    by = "rowname"
  ) %>%
  select(
    regija = NAME_1, long, lat
  ) %>%
  mutate(
    regija = replace(regija, regija == "Notranjsko-kraška", "Primorsko-notranjska"),
    regija = replace(regija, regija == "Spodnjeposavska", "Posavska")
  )
slo.regije.centroidi %>% write_csv("zemljevidi/si/regije-centroidi.csv")
#-------------------------------------------------------------------------------

# Prikaže le meje med regijami in njihova imena

slo.regije.poligoni %>% ggplot() +
  geom_polygon(
    mapping = aes(long, lat, group = group),
    color = "grey",
    fill = "white"
  ) +
  coord_map() +
  geom_text(
    data = slo.regije.centroidi,
    mapping = aes(x = long, y = lat, label = regija),
    size = 3
  ) +
  theme_classic() +
  theme(
    axis.line = element_blank(),
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    axis.title = element_blank()
  )
#-------------------------------------------------------------------------------

# Prostorska vizualizacija podatkov o prometnih nesrečah

slo.regije.poligoni <- read_csv("zemljevidi/si/regije-poligoni-vr.csv")

slo.regije.centroidi <- read_csv("zemljevidi/si/regije-centroidi-vr.csv")

# Zemljevid nesreč po regijah za leto 2020
graf.regije.nesrece.zemljevid <- tabela1 %>%
  filter(leto == zadnje.leto) %>%
  select(regija, st.nesrec.na.10000.preb) %>%
  filter(regija != "SLOVENIJA") %>%
  left_join(
    slo.regije.poligoni,
    by = "regija"
  ) %>%
  ggplot() +
  geom_polygon(
    mapping = aes(long, lat, group = group, fill = st.nesrec.na.10000.preb),
    color = "grey"
  ) +
  coord_map() +
  scale_fill_binned() +
  theme_classic() +
  theme(
    axis.line = element_blank(),
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    axis.title = element_blank()
  )

graf.regije.nesrece.zemljevid + 
  ggsave("regije-nesrece-mapa.pdf", dev = cairo_pdf, width = 9, height = 6) # Shranila zemljevid v datoteko







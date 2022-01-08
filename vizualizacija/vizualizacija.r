# 3. faza: Vizualizacija podatkov

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
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5))
#-------------------------------------------------------------------------------

# Graf števila nesreč na 10.000 prebivalcev v letu 2020

ggplot(tabela1.graf2, mapping = aes(x = reorder(regija, -st.nesrec.na.10000.preb), y = st.nesrec.na.10000.preb)) +
  geom_bar(stat = "identity") + 
  xlab("Regija") + ylab("Število nesreč na 10.000 prebivalcev") +
  ggtitle("Nesreče leta 2020") + 
  theme(axis.text.x = element_text(angle = 45, vjust = 0.5))
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

# Graf nesrec na vozilo v odvisnosti od nesrec na prebivalca, za regiji mojega doma in regijo fakultete

ggplot(tabela1 %>% filter(regija %in% c("Osrednjeslovenska", "Jugovzhodna Slovenija", "Posavska"))) + 
  aes(x = st.nesrec.na.1000.vozil, y = st.nesrec.na.10000.preb, color = leto, shape = regija) + 
  geom_point()

ggplot(tabela1 %>% filter(regija == "Osrednjeslovenska") %>% select(leto, indeks.rasti.nesrec)) + 
  aes(x = leto, y = indeks.rasti.nesrec) + 
  geom_line() + 
  xlab("Leto") + ylab("Indeks") + 
  ggtitle("Indeks rasti nesreč za Osrednjeslovensko")
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
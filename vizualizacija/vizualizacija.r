# 3. faza: 
# VIZUALIZACIJA PODATKOV

tabela = read_csv(
  "podatki/tabela.csv",
  locale = locale(encoding = "Windows-1250"),
  col_types = cols(
    .default = col_guess(),
    regija = col_factor()
  )
) %>% dplyr::select(-1)

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

graf.nesrece.2007 <- ggplot(tabela1.graf1, mapping = aes(x = reorder(regija, -st.nesrec.na.10000.preb), y = st.nesrec.na.10000.preb)) +
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

graf.nesrece.2020 <- ggplot(tabela1.graf2, mapping = aes(x = reorder(regija, -st.nesrec.na.10000.preb), y = st.nesrec.na.10000.preb)) +
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

graf.poskodovani <- tabela1 %>% filter(regija != "SLOVENIJA") %>%
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

graf.nesrece.vozila <- ggplot(tabela1) + 
  aes(x = leto, y = st.nesrec.na.1000.vozil) + 
  geom_col() + 
  facet_wrap(. ~ regija)
#-------------------------------------------------------------------------------

# Graf nesrec na vozilo v odvisnosti od nesrec na prebivalca, za regiji mojega doma in regijo fakultete

graf.nesrece.preb.vozila <- ggplot(tabela1 %>% filter(regija %in% c("Osrednjeslovenska", "Jugovzhodna Slovenija", "Posavska"))) + 
  aes(x = st.nesrec.na.1000.vozil, y = st.nesrec.na.10000.preb, color = leto, shape = regija) + 
  geom_point() + 
  xlab("Nesreče na 1.000 vozil") + ylab("Nesreče na 10.000 prebivalcev") + 
  ggtitle("Nesreče na vozilo v primerjavi \n z nesrečami na prebivalca treh regij")
#-------------------------------------------------------------------------------

# Indeks rasti nesreč za Osrednjeslovensko regijo

graf.indeks1 <- ggplot(tabela1 %>% filter(regija == "Osrednjeslovenska") %>% dplyr::select(leto, indeks.rasti.nesrec)) + 
  aes(x = leto, y = indeks.rasti.nesrec) + 
  geom_line() + 
  xlab("Leto") + ylab("Indeks") + 
  ggtitle("Indeks rasti nesreč za Osrednjeslovensko") + 
  theme_light()

# Indeks rasti nesreč za Slovenijo

graf.indeks2 <- ggplot(tabela1 %>% filter(regija == "SLOVENIJA") %>% dplyr::select(leto, indeks.rasti.nesrec)) + 
  aes(x = leto, y = indeks.rasti.nesrec) + 
  geom_line() + 
  xlab("Leto") + ylab("Indeks") + 
  ggtitle("Indeks rasti nesreč za Slovenijo") + 
  theme_minimal()
#-------------------------------------------------------------------------------

# Graf kvantilov za število nesreč
  
graf.kvantili.nesrece <- ggplot(tabela1 %>% mutate(leto = as.character(leto))) + # Dodala mutate, ker leto ni 'character'
  aes(x = leto, y = stevilo.nesrec) + 
  geom_boxplot(outlier.shape=8) + 
  xlab("Število nesreč") + ylab("Leto") + 
  ggtitle("Graf kvantilov za število \n nesreč za vsa leta")
#-------------------------------------------------------------------------------

# Graf kvantilov za število poškodovanih

graf.kvantili.poskodovani <- ggplot(tabela1 %>% mutate(leto = as.character(leto))) + # Dodala mutate, ker leto ni 'character'
  aes(x = leto, y = stevilo.poskodovanih) + 
  geom_boxplot(notch=TRUE) + 
  xlab("Število poškodovanih") + ylab("Leto") + 
  ggtitle("Graf kvantilov za število \n poškodovanih za vsa leta")
#-------------------------------------------------------------------------------

# Graf števila nesreč po letih, barvno ločeno po regijah

graf.nesrece.skupaj <- tabela1 %>%
  group_by(leto) %>%
  filter(regija != "SLOVENIJA") %>%
  ggplot(
    mapping = aes(x = leto, y = stevilo.nesrec, fill = reorder(regija, prebivalci))
  ) +
  geom_bar(
    stat = "identity",
    position = position_fill()
  ) + labs(fill="Regija") + 
  xlab("Leto") + ylab("Število nesreč") + 
  ggtitle("Delež nesreč po regijah")
  
################################################################################ 
# ZEMLJEVIDI
#-------------------------------------------------------------------------------

# Uvoz zemljevida

source("lib/uvozi.zemljevid.r")

Slovenija <- uvozi.zemljevid("http://biogeo.ucdavis.edu/data/gadm2.8/shp/SVN_adm_shp.zip",
                             "SVN_adm1", encoding="UTF-8") %>% fortify()
colnames(Slovenija)[12]<-'regija'  #preimenujemo stolpec
Slovenija$regija <- gsub('Notranjsko-kraška', 'Primorsko-notranjska', Slovenija$regija)
Slovenija$regija <- gsub('Spodnjeposavska', 'Posavska', Slovenija$regija)
#-------------------------------------------------------------------------------

# Prostorska vizualizacija podatkov o prometnih nesrečah
## Zemljevid nesreč po slovenskih statističnih regijah, leto 2020

tabela.za.zemljevid <- filter(tabela1, leto==2020) %>% dplyr::select(regija, leto, stevilo.nesrec)

zemljevid.nesrec1 <- ggplot() +
  geom_polygon(data = right_join(tabela.za.zemljevid, Slovenija, by = "regija"),
               aes(x = long, y = lat, group = group, fill = stevilo.nesrec))+
  ggtitle("Število nesreč po regijah \n za leto 2020") + 
  theme(axis.title=element_blank(), axis.text=element_blank(), 
        axis.ticks=element_blank(), panel.background = element_blank(),
        plot.title = element_text(hjust = 0.5)) +
  scale_fill_gradient(low = '#FCDADA', high='#970303') +
  labs(fill="Število po regijah") +
  geom_path(data = right_join(tabela.za.zemljevid, Slovenija,
                              by = "regija"), aes(x = long, y = lat, 
                                                             group = group), 
            color = "white", size = 0.1)

#-------------------------------------------------------------------------------

##Zemljevid nesreč po slovenskih statističnih regijah, leto 2007

tabela.za.zemljevid1 <- filter(tabela1, leto==2007) %>% dplyr::select(regija, leto, st.nesrec.na.10000.preb)

zemljevid.nesrec2 <- ggplot() +
  geom_polygon(data = right_join(tabela.za.zemljevid1, Slovenija, by = "regija"),
               aes(x = long, y = lat, group = group, fill = st.nesrec.na.10000.preb))+
  ggtitle("Število nesreč po regijah \n za leto 2007") + 
  theme(axis.title=element_blank(), axis.text=element_blank(), 
        axis.ticks=element_blank(), panel.background = element_blank(),
        plot.title = element_text(hjust = 0.5)) +
  scale_fill_gradient(low = 'lightpink1', high='indianred4') +
  labs(fill="Število po regijah") +
  geom_path(data = right_join(tabela.za.zemljevid1, Slovenija,
                              by = "regija"), aes(x = long, y = lat, 
                                                  group = group), 
            color = "white", size = 0.1)
#-------------------------------------------------------------------------------

##Zemljevid poškodovanih po slovenskih statističnih regijah, leto 2010

tabela.za.zemljevid2 <- filter(tabela1, leto==2010) %>% dplyr::select(regija, leto, st.poskodovanih.na.10000.preb)

zemljevid.poskodovanih <- ggplot() +
  geom_polygon(data = right_join(tabela.za.zemljevid2, Slovenija, by = "regija"),
               aes(x = long, y = lat, group = group, fill = st.poskodovanih.na.10000.preb))+
  ggtitle("Število poškodovanih po regijah \n za leto 2010") + 
  theme(axis.title=element_blank(), axis.text=element_blank(), 
        axis.ticks=element_blank(), panel.background = element_blank(),
        plot.title = element_text(hjust = 0.5)) +
  scale_fill_gradient(low = 'lightblue2', high='navyblue') +
  labs(fill="Število po regijah") +
  geom_path(data = right_join(tabela.za.zemljevid2, Slovenija,
                              by = "regija"), aes(x = long, y = lat, 
                                                  group = group), 
            color = "white", size = 0.1)

#-------------------------------------------------------------------------------

##Zemljevid indeksa prometnih nesreč po slovenskih statističnih regijah, leto 2019

tabela.za.zemljevid3 <- filter(tabela1, leto==2019) %>% dplyr::select(regija, leto, indeks.rasti.nesrec)

zemljevid.indeksa.nesrec <- ggplot() +
  geom_polygon(data = right_join(tabela.za.zemljevid3, Slovenija, by = "regija"),
               aes(x = long, y = lat, group = group, fill = indeks.rasti.nesrec))+
  ggtitle("Indeks nesreč po regijah \n za leto 2019") + 
  theme(axis.title=element_blank(), axis.text=element_blank(), 
        axis.ticks=element_blank(), panel.background = element_blank(),
        plot.title = element_text(hjust = 0.5)) +
  scale_fill_gradient(low = 'skyblue2', high='maroon4') +
  labs(fill="Indeks") +
  geom_path(data = right_join(tabela.za.zemljevid3, Slovenija,
                              by = "regija"), aes(x = long, y = lat, 
                                                  group = group), 
            color = "white", size = 0.1)


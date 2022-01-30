# 4. faza: Napredna analiza podatkov

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
    .default = col_guess()
  )
) %>% dplyr::select(-1)

tabela <- tabela %>% mutate(st.poskodovanih.na.10000.preb = stevilo.poskodovanih / prebivalci * 10000, 
                             st.nesrec.na.10000.preb = stevilo.nesrec / prebivalci * 10000, 
                             st.nesrec.na.1000.vozil = stevilo.nesrec / stevilo.vozil * 1000)

tabela1 <- tabela %>% 
  filter(regija != "SLOVENIJA", leto != 2007) %>%
  mutate(
    indeks.rasti.nesrec = stevilo.nesrec - lag(stevilo.nesrec), 
    indeks.rasti.poskodovanih = stevilo.poskodovanih - lag(stevilo.poskodovanih)
  )
tabela1$regija <- as.factor(tabela1$regija)

tabela2 <- tabela %>% 
  filter(regija != "SLOVENIJA", leto == 2019) %>%
  mutate(
    indeks.rasti.nesrec = stevilo.nesrec - lag(stevilo.nesrec), 
    indeks.rasti.poskodovanih = stevilo.poskodovanih - lag(stevilo.poskodovanih)
  ) %>%
  dplyr::select(regija, st.nesrec.na.10000.preb)
tabela2$regija <- as.factor(tabela2$regija)

source("lib/uvozi.zemljevid.r")

Slovenija <- uvozi.zemljevid("http://biogeo.ucdavis.edu/data/gadm2.8/shp/SVN_adm_shp.zip",
                             "SVN_adm1", encoding="UTF-8") %>% fortify()
Slovenija$NAME_1 <- gsub('Notranjsko-kraška', 'Primorsko-notranjska', Slovenija$NAME_1)
Slovenija$NAME_1 <- gsub('Spodnjeposavska', 'Posavska', Slovenija$NAME_1)

################################################################################

# Linearna regresija

g <- ggplot(tabela1, aes(x=stevilo.nesrec, y=stevilo.vozil)) + geom_point()
print(g)

lin.regresija <- g + geom_smooth(method="lm", formula = y ~ x)

################################################################################

# Metoda voditeljev

tabela2.norm <- tabela2 %>% dplyr::select(-regija) %>% scale()
rownames(tabela2.norm) <- tabela2$regija
k <- kmeans(tabela2.norm, 3, nstart = 1000)

head(k$cluster, n=12)
table(k$cluster)

k$tot.withinss

skupine <- data.frame(regija=tabela2$regija, skupina=factor(k$cluster))

# Skupine za regije:
# Pomurska                  2
# Podravska                 1
# Koroška                   2
# Savinjska                 1
# Zasavska                  3
# Posavska                  3
# Jugovzhodna Slovenija     2
# Osrednjeslovenska         1
# Gorenjska                 1
# Primorsko-notranjska      2
# Goriška                   2
# Obalno-kraška             1

################################################################################
# Metoda iz predavanj

regije <- tabela2[, 1] %>% unlist()
razdalje <- tabela2[, -1] %>% dist()
dendrogram <- razdalje %>% hclust(method = "ward.D")

# Dendrogram razdalj med regijami glede na podatke o številu nesreč

plot(
  dendrogram,
  labels = regije,
  xlab = "regija",
  ylab = "višina",
  main = "Wardova razdalja med regijami"
)

# Metoda voditeljev

skupine2 = tabela2[, -1] %>%
  kmeans(centers = 3) %>%
  getElement("cluster") %>%
  as.ordered()

r.hc <- tabela2[, -1] %>% obrisi(hc = TRUE)

# Kolena

dendrogram %>%
  hc.kolena() %>%
  diagram.kolena()
# Kolena : 2, 3, 4, 6, 8

# Obrisi

regije.x.y <-
  as_tibble(razdalje %>% cmdscale(k = 2)) %>%
  bind_cols(regije) %>%
  dplyr::select(regija = ...3, x = V1, y = V2)

# Razdelimo regije na 4 skupine

k <- obrisi.k(r.hc)
skupine2 <- tabela2[, -1] %>%
  dist() %>%
  hclust(method = "ward.D") %>%
  cutree(k = k) %>%
  as.ordered()
diagram.skupine(regije.x.y, regije.x.y$regija, skupine2, k)

# Razdelimo regije na 3 skupine

set.seed(20) # ponovljivost rezultatov
skupine2 <- tabela2[, -1] %>%
  kmeans(centers = 3) %>%
  getElement("cluster") %>%
  as.ordered()

skupina.treh <- diagram.skupine(regije.x.y, regije.x.y$regija, skupine2, k)


################################################################################
# Napovedovanje
#-------------------------------------------------------------------------------
# Priprava:

lin <- lm(data = tabela, stevilo.nesrec ~ prebivalci)
g <- ggplot(tabela, aes(x=prebivalci, y=stevilo.nesrec)) + geom_point()
#-------------------------------------------------------------------------------

# Prileganje z zlepki:

z <- lowess(tabela$prebivalci, tabela$stevilo.nesrec)
g + geom_line(data=as.data.frame(z), aes(x=x, y=y), color="green")
#-------------------------------------------------------------------------------

# Model:
# Iz tega modela lahko delamo tudi napovedi. 

mls <- loess(data=tabela, stevilo.nesrec ~ prebivalci)
napovedni.model <- g + geom_smooth(method="loess")

# napovedi <- predict(mls, data.frame(prebivalci=seq(1000, 800000, 2000000)))

# g + geom_line(data = data.frame(prebivalci=seq(1000, 800000, 2000000), napovedi = napovedi),
#               aes(x = prebivalci, y = napovedi), col = "blue")
#-------------------------------------------------------------------------------

# Kvadratne napake: 

sapply(list(lin, mls), function(x) mean((x$residuals^2)))
# Vrne nam: 1390918, 1132940




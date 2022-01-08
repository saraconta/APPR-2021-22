# 2. faza: Uvoz podatkov


sl <- locale("sl", decimal_mark=",", grouping_mark=".")

################################################################################

# Branje podatkov:

prebivalstvo <- read_csv(
  "podatki/regije-prebivalstvo.csv",
  skip = 2,
  col_names = TRUE,
  locale = locale(encoding = "Windows-1250"),
  col_types = cols(
    .default = col_guess()
    )
  )
#-------------------------------------------------------------------------------
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
vozila[is.na(vozila)]<-0 # zaradi napak spremenila vrednosti NA v 0
#-------------------------------------------------------------------------------
nesrece.2015 <- read_excel("podatki/nesrece-2015.xlsx", sheet = "nesrece-2015")
#-------------------------------------------------------------------------------
nesrece.2016 <- read_excel("podatki/nesrece-2016.xlsx", sheet = "pn2016")
#-------------------------------------------------------------------------------
nesrece.2017 <- read_excel("podatki/nesrece-2017.xlsx", sheet = "nesrece-2017")
#-------------------------------------------------------------------------------
nesrece.2018 <- read_excel("podatki/nesrece-2018.xlsx", sheet = "nesrece-2018")
#-------------------------------------------------------------------------------
nesrece.2019 <- read_excel("podatki/nesrece-2019.xlsx", sheet = "nesrece-2019")
#-------------------------------------------------------------------------------
nesrece.2020 <- read_excel("podatki/nesrece-2020.xlsx", sheet = "nesrece-2020")
#-------------------------------------------------------------------------------
nesrece.udelezenci <- read_csv(
  "podatki/regije-nesrece-udelezenci.csv",
  skip = 2,
  col_names = TRUE,
  locale = locale(encoding = "Windows-1250"),
  col_types = cols(
    .default = col_guess()
    )
  )
#-------------------------------------------------------------------------------
nesrece <- read_csv(
  "podatki/regije-nesrece.csv",
  skip = 2,
  col_names = TRUE,
  locale = locale(encoding = "Windows-1250"),
  col_types = cols(
    .default = col_guess()
    )
  )
#-------------------------------------------------------------------------------
obcine.regije <- read_csv(
  "podatki/obcine-regije.csv",
  col_names = TRUE,
  locale = locale(encoding = "utf-8"),
  col_types = cols(
    .default = col_guess()
    )
  )

################################################################################

# Čiščenje podatkov
#-------------------------------------------------------------------------------
# 1. Urejanje pivotnih tabel
#-------------------------------------------------------------------------------
# tabela obcine.regije:

obcine.regije <- obcine.regije %>% 
  add_row(obcina="SLOVENIJA", regija="SLOVENIJA") # dodala stolpec zaradi left joina
obcine.regije[obcine.regije=="Dobrovnik/Dobronak"] <- "Dobrovnik"
obcine.regije[obcine.regije=="Hodoš/Hodos"] <- "Hodoš"
obcine.regije[obcine.regije=="Lendava/Lendva"] <- "Lendava"
obcine.regije[obcine.regije=="Ankaran/Ancarano"] <- "Ankaran"
obcine.regije[obcine.regije=="Izola/Isola"] <- "Izola"
obcine.regije[obcine.regije=="Koper/Capodistria"] <- "Koper"
obcine.regije[obcine.regije=="Piran/Pirano"] <- "Piran"
obcine.regije[obcine.regije=="Šentjur"] <- "Šentjur Pri Celju" # se ne ujema z občino v drugih tabelah(velja tudi za vse predhodnje)

obcine.regije1 <- obcine.regije %>% 
  mutate(obcina = str_to_title(obcina)) # zaradi združevanja preoblikovala imena občin

#-------------------------------------------------------------------------------
# tabela prebivalstva:

prebivalstvo1 <- pivot_longer(prebivalstvo,
                                cols = colnames(prebivalstvo)[-1],
                                names_to = "leto",
                                values_to = "prebivalci"
) %>% 
  rename("regija"="STATISTIČNA REGIJA")

prebivalstvo1$leto <- as.numeric(prebivalstvo1$leto) # Spremenila tip stolpca leto

#-------------------------------------------------------------------------------
# tabela nesreč:

nesrece1 <- pivot_longer(nesrece, 
                         cols = colnames(nesrece)[-1],
                         names_to = "leto.vrsta",
                         values_to = "stevilo.nesrec"
) %>% 
  rename("regija"="STATISTIČNA REGIJA") %>%
  tidyr::extract(
    col = leto.vrsta,
    into = c("leto", "vrsta"),
    regex = "^(\\d{4})\\s[A-zčšžČŠŽ]+\\s[A-zčŠŽčšž]+\\s+-*\\s*+[sz]*\\s*(.*)$"
  ) %>% 
  filter(vrsta=="SKUPAJ") %>% 
  replace("SKUPAJ", "skupaj") %>% 
  select(regija, leto, stevilo.nesrec)

nesrece1[nesrece1=="Spodnjeposavska"] <- "Posavska"

nesrece1[nesrece1=="Notranjsko-kraška"] <- "Primorsko-notranjska"

#-------------------------------------------------------------------------------
# tabela vozil:

vozila1 <- pivot_longer(vozila,
                        cols = colnames(vozila)[-1],
                        names_to = "leto",
                        values_to = "stevilo.vozil"
) %>% 
  rename("obcina"="OBČINE")
vozila1[vozila1=="Dobrovnik/Dobronak"] <- "Dobrovnik"
vozila1[vozila1=="Hodoš/Hodos"] <- "Hodoš"
vozila1[vozila1=="Lendava/Lendva"] <- "Lendava"
vozila1[vozila1=="Ankaran/Ancarano"] <- "Ankaran"
vozila1[vozila1=="Izola/Isola"] <- "Izola"
vozila1[vozila1=="Koper/Capodistria"] <- "Koper"
vozila1[vozila1=="Piran/Pirano"] <- "Piran"
vozila1[vozila1=="Šentjur"] <- "Šentjur Pri Celju"

vozila1$leto <- as.numeric(vozila1$leto)

#-------------------------------------------------------------------------------
# tabela udeležencev:

nesrece_udelezenci1 <- pivot_longer(nesrece.udelezenci,
                                   cols = colnames(nesrece.udelezenci)[-1],
                                   names_to = "leto.poskodba",
                                   values_to = "stevilo.poskodovanih"
) %>% 
  rename("regija"="STATISTIČNA REGIJA") %>%
  tidyr::extract(
    col = leto.poskodba,
    into = c("leto", "poskodba"),
    regex = "^(\\d{4})\\s[A-zčšžČŠŽ]+\\s[A-zčŠŽčšž]+\\s+-*\\s*+[sz]*\\s*(.*)$"
  ) %>% 
  filter(poskodba=="SKUPAJ") %>%
  select(regija, leto, stevilo.poskodovanih)

nesrece_udelezenci1[nesrece_udelezenci1=="Spodnjeposavska"] <- "Posavska"  # v ostalih tabelah zapisana drugače

nesrece_udelezenci1[nesrece_udelezenci1=="Notranjsko-kraška"] <- "Primorsko-notranjska" # v ostalih tabelah zapisana drugače

#-------------------------------------------------------------------------------
# tabele nesreč med leti 2015 in 2020:

nesrece_2015 <- nesrece.2015 %>% 
  select(ZaporednaStevilkaPN, KlasifikacijaNesrece, UpravnaEnotaStoritve) %>%
  rename("stevilka-nesrece"="ZaporednaStevilkaPN", "vrsta"="KlasifikacijaNesrece", "obcina"="UpravnaEnotaStoritve") %>% 
  mutate(vrsta=tolower(vrsta), obcina=str_to_title(obcina)) %>%
  left_join(obcine.regije1, by="obcina")

nesrece_2015$stevilo.nesrec <- 1

nesrece_2015 <- nesrece_2015 %>% 
  distinct() %>% 
  select(regija, stevilo.nesrec) %>% 
  group_by(regija) %>% 
  summarise(stevilo.nesrec=sum(stevilo.nesrec))

nesrece_2015 <- nesrece_2015[-nrow(nesrece_2015),] # Izbrišemo vrstico z na vrednostjo

nesrece_2015$leto <- 2015

nesrece_2015 <- nesrece_2015 %>% 
  add_row(regija="SLOVENIJA", stevilo.nesrec=sum(nesrece_2015$stevilo.nesrec) ,leto=2015) # dodala stolpec zaradi left joina

#-------------------------------------------------------------------------------
nesrece_2016 <- nesrece.2016 %>% 
  select(ZaporednaStevilkaPN, KlasifikacijaNesrece, UpravnaEnotaStoritve) %>%
  rename("stevilka-nesrece"="ZaporednaStevilkaPN", "vrsta"="KlasifikacijaNesrece", "obcina"="UpravnaEnotaStoritve") %>% 
  mutate(vrsta=tolower(vrsta), obcina=str_to_title(obcina)) %>%
  left_join(obcine.regije1, by="obcina")

nesrece_2016$stevilo.nesrec <- 1

nesrece_2016 <- nesrece_2016 %>% 
  distinct() %>% 
  select(regija, stevilo.nesrec) %>% 
  group_by(regija) %>% 
  summarise(stevilo.nesrec=sum(stevilo.nesrec))

nesrece_2016 <- nesrece_2016[-nrow(nesrece_2016),]# Izbrišemo na

nesrece_2016$leto <- 2016

nesrece_2016 <- nesrece_2016 %>% 
  add_row(regija="SLOVENIJA", stevilo.nesrec=sum(nesrece_2016$stevilo.nesrec), leto=2016) # dodala stolpec zaradi left joina

#-------------------------------------------------------------------------------
nesrece_2017 <- nesrece.2017 %>% 
  select(ZaporednaStevilkaPN, KlasifikacijaNesrece, UpravnaEnotaStoritve) %>%
  rename("stevilka-nesrece"="ZaporednaStevilkaPN", "vrsta"="KlasifikacijaNesrece", "obcina"="UpravnaEnotaStoritve") %>% 
  mutate(vrsta=tolower(vrsta), obcina=str_to_title(obcina)) %>%
  left_join(obcine.regije1, by="obcina")

nesrece_2017$stevilo.nesrec <- 1

nesrece_2017 <- nesrece_2017 %>% 
  distinct() %>% 
  select(regija, stevilo.nesrec) %>% 
  group_by(regija) %>% 
  summarise(stevilo.nesrec=sum(stevilo.nesrec))

nesrece_2017 <- nesrece_2017[-nrow(nesrece_2017),]# izbrisemo na

nesrece_2017$leto <- 2017

nesrece_2017 <- nesrece_2017 %>% 
  add_row(regija="SLOVENIJA", stevilo.nesrec=sum(nesrece_2017$stevilo.nesrec), leto=2017) # dodala stolpec zaradi left joina

#-------------------------------------------------------------------------------
nesrece_2018 <- nesrece.2018 %>% 
  select(ZaporednaStevilkaPN, KlasifikacijaNesrece, UpravnaEnotaStoritve) %>%
  rename("stevilka-nesrece"="ZaporednaStevilkaPN", "vrsta"="KlasifikacijaNesrece", "obcina"="UpravnaEnotaStoritve") %>% 
  mutate(vrsta=tolower(vrsta), obcina=str_to_title(obcina)) %>%
  left_join(obcine.regije1, by="obcina")

nesrece_2018$stevilo.nesrec <- 1

nesrece_2018 <- nesrece_2018 %>% 
  distinct() %>% 
  select(regija, stevilo.nesrec) %>% 
  group_by(regija) %>% 
  summarise(stevilo.nesrec=sum(stevilo.nesrec))

nesrece_2018 <- nesrece_2018[-nrow(nesrece_2018),]

nesrece_2018$leto <- 2018

nesrece_2018 <- nesrece_2018 %>% 
  add_row(regija="SLOVENIJA", stevilo.nesrec=sum(nesrece_2018$stevilo.nesrec), leto=2018) # dodala stolpec zaradi left joina

#-------------------------------------------------------------------------------
nesrece_2019 <- nesrece.2019 %>% 
  select(ZaporednaStevilkaPN, KlasifikacijaNesrece, UpravnaEnotaStoritve) %>%
  rename("stevilka-nesrece"="ZaporednaStevilkaPN", "vrsta"="KlasifikacijaNesrece", "obcina"="UpravnaEnotaStoritve") %>% 
  mutate(vrsta=tolower(vrsta), obcina=str_to_title(obcina)) %>%
  left_join(obcine.regije1, by="obcina")

nesrece_2019$stevilo.nesrec <- 1

nesrece_2019 <- nesrece_2019 %>% 
  distinct() %>% 
  select(regija, stevilo.nesrec) %>% 
  group_by(regija) %>% 
  summarise(stevilo.nesrec=sum(stevilo.nesrec))

nesrece_2019 <- nesrece_2019[-nrow(nesrece_2019),]

nesrece_2019$leto <- 2019

nesrece_2019 <- nesrece_2019 %>% 
  add_row(regija="SLOVENIJA", stevilo.nesrec=sum(nesrece_2019$stevilo.nesrec), leto=2019) # dodala stolpec zaradi left joina

#-------------------------------------------------------------------------------
nesrece_2020 <- nesrece.2020 %>% 
  select(ZaporednaStevilkaPN, KlasifikacijaNesrece, UpravnaEnotaStoritve) %>%
  rename("stevilka-nesrece"="ZaporednaStevilkaPN", "vrsta"="KlasifikacijaNesrece", "obcina"="UpravnaEnotaStoritve") %>% 
  mutate(vrsta=tolower(vrsta), obcina=str_to_title(obcina)) %>%
  left_join(obcine.regije1, by="obcina")

nesrece_2020$stevilo.nesrec <- 1

nesrece_2020 <- nesrece_2020 %>% 
  distinct() %>% select(regija, stevilo.nesrec) %>% 
  group_by(regija) %>% 
  summarise(stevilo.nesrec=sum(stevilo.nesrec))

nesrece_2020 <- nesrece_2020[-nrow(nesrece_2020),]

nesrece_2020$leto <- 2020

nesrece_2020 <- nesrece_2020 %>% 
  add_row(regija="SLOVENIJA", stevilo.nesrec=sum(nesrece_2020$stevilo.nesrec), leto=2020) # dodala stolpec zaradi left joina

#-------------------------------------------------------------------------------
# tabele udeležencev med leti 2015 in 2020:

nesrece_udelezenci_2015 <- nesrece.2015 %>% 
  select(UpravnaEnotaStoritve) %>%
  rename("obcina"="UpravnaEnotaStoritve") %>% 
  mutate(obcina=str_to_title(obcina)) # občine spremenila v male tiskane z veliko začetnico, poškodbe pa v male tiskane

nesrece_udelezenci_2015$stevilo.poskodovanih <- 1

nesrece_udelezenci_2015 <- nesrece_udelezenci_2015 %>% 
  left_join(obcine.regije1, by="obcina") %>% 
  select(stevilo.poskodovanih, regija) %>%
  group_by(regija) %>% 
  summarise(stevilo.poskodovanih=sum(stevilo.poskodovanih))

nesrece_udelezenci_2015 <- nesrece_udelezenci_2015[-nrow(nesrece_udelezenci_2015),]

nesrece_udelezenci_2015$leto <- 2015

nesrece_udelezenci_2015 <- nesrece_udelezenci_2015 %>% 
  add_row(regija="SLOVENIJA", stevilo.poskodovanih=sum(nesrece_udelezenci_2015$stevilo.poskodovanih), leto=2015) # dodala stolpec zaradi left joina

#-------------------------------------------------------------------------------
nesrece_udelezenci_2016 <- nesrece.2016 %>% 
  select(UpravnaEnotaStoritve, PoskodbaUdelezenca) %>%
  rename("obcina"="UpravnaEnotaStoritve", "poskodba"="PoskodbaUdelezenca") %>% 
  mutate(poskodba=tolower(poskodba), obcina=str_to_title(obcina))

nesrece_udelezenci_2016$stevilo.poskodovanih <- 1

nesrece_udelezenci_2016 <- nesrece_udelezenci_2016 %>% 
  left_join(obcine.regije1, by="obcina") %>% 
  select(stevilo.poskodovanih, regija) %>%
  group_by(regija) %>% 
  summarise(stevilo.poskodovanih=sum(stevilo.poskodovanih))

nesrece_udelezenci_2016 <- nesrece_udelezenci_2016[-nrow(nesrece_udelezenci_2016),]

nesrece_udelezenci_2016$leto <- 2016

nesrece_udelezenci_2016 <- nesrece_udelezenci_2016 %>% 
  add_row(regija="SLOVENIJA", stevilo.poskodovanih=sum(nesrece_udelezenci_2016$stevilo.poskodovanih), leto=2016) # dodala stolpec zaradi left joina

#-------------------------------------------------------------------------------
nesrece_udelezenci_2017 <- nesrece.2017 %>% 
  select(UpravnaEnotaStoritve, PoskodbaUdelezenca) %>%
  rename("obcina"="UpravnaEnotaStoritve", "poskodba"="PoskodbaUdelezenca") %>% 
  mutate(poskodba=tolower(poskodba), obcina=str_to_title(obcina))

nesrece_udelezenci_2017$stevilo.poskodovanih <- 1

nesrece_udelezenci_2017 <- nesrece_udelezenci_2017 %>% 
  left_join(obcine.regije1, by="obcina") %>% 
  select(stevilo.poskodovanih, regija) %>%
  group_by(regija) %>% 
  summarise(stevilo.poskodovanih=sum(stevilo.poskodovanih))

nesrece_udelezenci_2017 <- nesrece_udelezenci_2017[-nrow(nesrece_udelezenci_2017),]

nesrece_udelezenci_2017$leto <- 2017

nesrece_udelezenci_2017 <- nesrece_udelezenci_2017 %>% 
  add_row(regija="SLOVENIJA", stevilo.poskodovanih=sum(nesrece_udelezenci_2017$stevilo.poskodovanih), leto=2017) # dodala stolpec zaradi left joina

#-------------------------------------------------------------------------------
nesrece_udelezenci_2018 <- nesrece.2018 %>% 
  select(UpravnaEnotaStoritve, PoskodbaUdelezenca) %>%
  rename("obcina"="UpravnaEnotaStoritve", "poskodba"="PoskodbaUdelezenca") %>% 
  mutate(poskodba=tolower(poskodba), obcina=str_to_title(obcina))

nesrece_udelezenci_2018$stevilo.poskodovanih <- 1

nesrece_udelezenci_2018 <- nesrece_udelezenci_2018 %>% 
  left_join(obcine.regije1, by="obcina") %>% 
  select(stevilo.poskodovanih, regija) %>%
  group_by(regija) %>% 
  summarise(stevilo.poskodovanih=sum(stevilo.poskodovanih))

nesrece_udelezenci_2018 <- nesrece_udelezenci_2018[-nrow(nesrece_udelezenci_2018),]

nesrece_udelezenci_2018$leto <- 2018

nesrece_udelezenci_2018 <- nesrece_udelezenci_2018 %>% 
  add_row(regija="SLOVENIJA", stevilo.poskodovanih=sum(nesrece_udelezenci_2018$stevilo.poskodovanih), leto=2018) # dodala stolpec zaradi left joina

#-------------------------------------------------------------------------------
nesrece_udelezenci_2019 <- nesrece.2019 %>% 
  select(UpravnaEnotaStoritve, PoskodbaUdelezenca) %>%
  rename("obcina"="UpravnaEnotaStoritve", "poskodba"="PoskodbaUdelezenca") %>% 
  mutate(poskodba=tolower(poskodba), obcina=str_to_title(obcina))

nesrece_udelezenci_2019$stevilo.poskodovanih <- 1

nesrece_udelezenci_2019 <- nesrece_udelezenci_2019 %>% 
  left_join(obcine.regije1, by="obcina") %>% 
  select(stevilo.poskodovanih, regija) %>%
  group_by(regija) %>% 
  summarise(stevilo.poskodovanih=sum(stevilo.poskodovanih))

nesrece_udelezenci_2019 <- nesrece_udelezenci_2019[-nrow(nesrece_udelezenci_2019),]

nesrece_udelezenci_2019$leto <- 2019

nesrece_udelezenci_2019 <- nesrece_udelezenci_2019 %>% 
  add_row(regija="SLOVENIJA", stevilo.poskodovanih=sum(nesrece_udelezenci_2019$stevilo.poskodovanih), leto=2019) # dodala stolpec zaradi left joina

#-------------------------------------------------------------------------------
nesrece_udelezenci_2020 <- nesrece.2020 %>% 
  select(UpravnaEnotaStoritve, PoskodbaUdelezenca) %>%
  rename("obcina"="UpravnaEnotaStoritve", "poskodba"="PoskodbaUdelezenca") %>% 
  mutate(poskodba=tolower(poskodba), obcina=str_to_title(obcina))

nesrece_udelezenci_2020$stevilo.poskodovanih <- 1

nesrece_udelezenci_2020 <- nesrece_udelezenci_2020 %>% 
  left_join(obcine.regije1, by="obcina") %>% 
  select(stevilo.poskodovanih, regija) %>%
  group_by(regija) %>% 
  summarise(stevilo.poskodovanih=sum(stevilo.poskodovanih))

nesrece_udelezenci_2020 <- nesrece_udelezenci_2020[-nrow(nesrece_udelezenci_2020),]

nesrece_udelezenci_2020$leto <- 2020

nesrece_udelezenci_2020 <- nesrece_udelezenci_2020 %>% 
  add_row(regija="SLOVENIJA", stevilo.poskodovanih=sum(nesrece_udelezenci_2020$stevilo.poskodovanih), leto=2020) # dodala stolpec zaradi left joina

#-------------------------------------------------------------------------------
# 2. Združevanje tabel
#-------------------------------------------------------------------------------
# Združitev tabele vozil in regij:

vozila2 <- vozila1 %>% 
  left_join(obcine.regije, by="obcina") %>% 
  select(-1) %>% 
  group_by(leto, regija) %>% 
  summarise(stevilo.vozil=sum(stevilo.vozil)) %>% 
  arrange("leto", "regija", "stevilo-vozil")

#-------------------------------------------------------------------------------
# Združitev vseh tabel o poškodovanih:

nesrece_udelezenci2 <- nesrece_udelezenci1 %>% 
  rbind(nesrece_udelezenci_2015) %>% 
  rbind(nesrece_udelezenci_2016) %>% 
  rbind(nesrece_udelezenci_2017) %>% 
  rbind(nesrece_udelezenci_2018) %>% 
  rbind(nesrece_udelezenci_2019) %>% 
  rbind(nesrece_udelezenci_2020)

#-------------------------------------------------------------------------------
# Združitev vseh tabel o nesrečah:

nesrece2 <- nesrece1 %>% 
  rbind(nesrece_2015) %>% 
  rbind(nesrece_2016) %>% 
  rbind(nesrece_2017) %>% 
  rbind(nesrece_2018) %>% 
  rbind(nesrece_2019) %>% 
  rbind(nesrece_2020)

#-------------------------------------------------------------------------------
# Združitev vseh novonastalih tabel in tabele o prebivalstvu:

tabela <- prebivalstvo1 %>% 
  left_join(nesrece_udelezenci2, by="regija") %>% 
  filter(leto.x == leto.y) %>% 
  select(regija, "leto"=leto.x, prebivalci, stevilo.poskodovanih) %>% 
  left_join(nesrece2, by="regija") %>% 
  filter(leto.x == leto.y) %>% 
  select(regija, "leto"=leto.x, prebivalci, stevilo.poskodovanih, stevilo.nesrec) %>% 
  left_join(vozila2, by="regija") %>% 
  filter(leto.x == leto.y) %>%
  select(regija, "leto"=leto.x, prebivalci, stevilo.poskodovanih, stevilo.nesrec, stevilo.vozil)

#-------------------------------------------------------------------------------
# Shranjevanje tabele v datoteko:

tabela %>% write.csv("tabela.csv")

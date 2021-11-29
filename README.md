# Analiza prometnih nesreč v Sloveniji v letih 2007-2014


## Tematika

### Osnovna ideja
Pri pregledu podatkovne baze Si-Stat mi je takoj padla v oči tematika o prometnih nesrečah. Statistični podatki so se mi zdeli obetavni za nadaljnje delo in preučevanje. Nameravam preučiti delež poškodovanih na prebivalca po regijah in pa delež nesreč na število osebnih vozil v regiji, saj se mi zdi, da so ti podatki medsebojno odvisni. Predvidevam, da se bo število nesreč povečevalo tako s številom prebivalcev kot tudi s številom vozil. Edina slaba točka tega projekta je zastarelost podatkov, saj sem na Si-Statu našla le podatke do leta 2014. Iz teh podatkov bom še vedno skušala izluščiti čim več informacij ter jih ustrezno analizirati.

### Opis podatkovnih virov
- [Cestnoprometne nesreče in udeleženci v nesrečah, statistične regije, Slovenija, 2007 - 2014](https://pxweb.stat.si/SiStatData/pxweb/sl/Data/-/2222008S.px): Na tej povezavi so podatki o cestnoprometnih nesrečah in udeležencih v nesrečah po statističnih regijah v letih 2007 - 2014. Podatki so na voljo v obliki csv.
- [Cestna vozila konec leta (31.12.) glede na vrsto vozila in občino, Slovenija, letno](https://pxweb.stat.si/SiStatData/pxweb/sl/Data/-/2222105S.px): Na tej povezavi so podatki o številu cestnih vozil v posameznih občinah po letih. Podatki so na voljo v obliki csv.
- [Prebivalstvo po velikih in petletnih starostnih skupinah in spolu, statistične regije, Slovenija, letno](https://pxweb.stat.si/SiStatData/pxweb/sl/Data/-/05C2002S.px) Tu so zbrani podatki o številu prebivalcev po regijah po letih; spol in starost nas ne zanimata. Podatki so na voljo v obliki csv.
- [Statistične regije Slovenije](https://sl.wikipedia.org/wiki/Statisti%C4%8Dne_regije_Slovenije#Ob%C4%8Dine_po_statisti%C4%8Dnih_regijah): Tu je povezava do strani na wikipediji, ki vsebuje tabelo o pripadnosti občin regijam. Podatki so na voljo v obliki html.

### Zasnova podatkovnih virov
Ko bom vse podatke ustrezno prenesla, jih bo treba preurediti v ustrezno obliko. 
Podatke o nesrečah bom preoblikovala tako, da bo nova tabela vsebovala pet stolpcev:
* Leto
* Regija
* Škoda (ugotoviti moram, kako ločiti podatke, saj so zbrani skupaj s podatki o udeležencih)
* Udeleženci glede na posledice (ugotoviti moram, kako ločiti podatke, saj so zbrani skupaj s podatki o škodi)
* Število
Podatke o cestnih vozilih bom preuredila v tri stolpce:
* Leto
* Občina
* Število
Podatke o prebivalstvu bom preuredila v tri stolpce:
* Leto
* Regija
* Število
Tabele iz wikipedije ne bom preurejala; služila bo le za pretvarjanje podatkov o cestnih vozilih po občinah na podatke po regijah.

### Plan dela
Na začetku se bom osredotočila na urejanje podatkov. Tabele bom naložila in s pomočjo funkcij iz knjižnice 'tidyverse'. Ko bodo vsi podatki zbrani in urejeni, bom združila tabele v eno samo tako, da bo za vsako vrednost iz prve tabele poleg moč videti tudi število prebivalcev in število vozil tistega leta v tisti regiji. Najprej bo seveda treba preoblikovati tabelo o vozilih tako, da bo prikazovala število vozil na regijo namesto na občino. Ko bo obstajala ena sama tabela, bom izračunala nekaj novih podatkov, ki se mi zdijo pomembni za statistično preučevanje. Za vsako vrednost bom dodala nove stolpec, ki bodo prikazovali: 
* delež udeležencev na prebivalca,
* delež nesreč na prebivalca,
* delež nesreč na število vozil,
* delež udeležencev na število vozil.
Kateri izmed teh podatkov bodo za mojo analizo pomembnejši, bom ugotovila skozi postopek urejanja podatkov.

Ko bo to storjeno, bom poskušala izrisati kakšne grafe teh deležev za vse regije in opazovala podobnosti v obliki, rasteh in padcih ter številkah. 

Ker se mi zdi pomembno opazovati tudi spreminjanje številk skozi čas, bom dodala še en stolpec, ki bo prikazoval razliko med vrednostmi tega leta in preteklega. Tako bomo lahko opazovali, ali je število nesreč raslo ali padalo.

## Program

Glavni program in poročilo se nahajata v datoteki `projekt.Rmd`.
Ko ga prevedemo, se izvedejo programi, ki ustrezajo drugi, tretji in četrti fazi projekta:

* obdelava, uvoz in čiščenje podatkov: `uvoz/uvoz.r`
* analiza in vizualizacija podatkov: `vizualizacija/vizualizacija.r`
* napredna analiza podatkov: `analiza/analiza.r`

Vnaprej pripravljene funkcije se nahajajo v datotekah v mapi `lib/`.
Potrebne knjižnice so v datoteki `lib/libraries.r`
Podatkovni viri so v mapi `podatki/`.
Zemljevidi v obliki SHP, ki jih program pobere,
se shranijo v mapo `../zemljevidi/` (torej izven mape projekta).


## Palvelimen valmistelu ja CI/CD-yhteyden rakentaminen

Useimmat kurssiprojektit käyttävät valmiita PaaS-palveluita, kuten Renderiä, Herokua, Rahtia tai Verceliä, koska deployment on niiden kanssa helppoa ja nopeaa. Minä päätin kuitenkin rakentaa sovellukselle oman VPS-ympäristön DigitalOceaniin.

Hyödynsin vahvasti Linux-palvelimet-kurssilla opittuja taitoja palvelimen pystytyksessä. Kurssilla käytiin läpi palvelimen peruskonfigurointia, palomuuria, Nginx:ää ja yleistä Linux-hallintaa, joten sain hyvän lähtökohdan projektille. Tämän takia osa alkuvaiheen asetuksista (kuten käyttäjän luonti, SSH-avaimet ja palomuurin säätäminen) ei ole erikseen dokumentoitu tähän raporttiin.

### Palvelinympäristö

Sovellus pyörii DigitalOceanin Droplet-palvelimella seuraavilla spekseillä:

- **Käyttöjärjestelmä**: Debian 13 (x64)
- **Muisti**: 1 GB RAM  
- **Suoritin**: 1 vCPU  
- **Tallennustila**: 25 GB SSD  
- **Sijainti**: Amsterdam (AMS3)

Palvelimelle asetin UFW-palomuurin ja Nginx-reverse proxyn hoitamaan liikennettä. HTTPS-salaus toteutettiin Let's Encrypt -sertifikaateilla, ja kokonaisuus sai SSL Labs -testistä arvosanan **A+**.

### Infrastruktuurin toteutus

Aloitin infran rakentamisen puhtaasta Debian 13 -asennuksesta. Tavoitteenani oli luoda turvallinen, toistettava ja automatisoitava alusta kontitetuille sovelluksille.

Sovellus on kokonaan paketoitu Docker-konteiksi, ja koko stackia (frontend, backend sekä tietokanta) hallitaan yhdellä `docker-compose.yml`-tiedostolla. Tämän ansiosta kehitys- ja tuotantoympäristöt ovat mahdollisimman identtiset.

Lisäksi rakensin GitHub Actions -pohjaisen CI/CD-putken, joka suorittaa automaattiset E2E-testaukset (Robot Framework) aina pull requestin yhteydessä. Näin varmistetaan, että vain toimiva koodi pääsee tuotantoon.

---

### 1. Dockerin asennus
Aloitin palvelimen valmistelun päivittämällä järjestelmän ja asentamalla Dockerin virallisen version Debian 13:lle.

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg

# Dockerin virallinen GPG-avain
sudo rm -f /etc/apt/keyrings/docker.gpg
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Lisätään Dockerin repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### 2. Käyttöoikeuksien konfigurointi
Jotta pystyn hallitsemaan kontteja ja jotta CI/CD-automaatio pystyy ajamaan komentoja ilman root-oikeuksia, lisäsin käyttäjätunnukseni docker-ryhmään ja varmistin asennuksen onnistumisen:

```bash
sudo usermod -aG docker $USER
newgrp docker
docker ps
```
<img width="787" height="238" alt="linuxDocker" src="https://github.com/user-attachments/assets/c320c019-cd33-4747-934a-ea61fae08ac9" />

### 3. Yhteyden luominen GitHub Actionsille
Varmistaakseni automaattisten deploymentien toiminnan, loin palvelimelle erillisen, salasanattoman SSH-avaimen (ed25519) yksinomaan GitHub Actionsia varten.

```bash
# Luodaan uusi avain
ssh-keygen -t ed25519 -f ~/.ssh/github_actions -N "" -C "github-actions-deploy"

# Valtuutetaan luotu avain palvelimella
cat ~/.ssh/github_actions.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Tulostetaan yksityinen avain GitHubia varten
cat ~/.ssh/github_actions
```

<img width="898" height="712" alt="secrets" src="https://github.com/user-attachments/assets/25266f77-5c50-4130-9bad-acf67e307454" /><


Siirsin luomani yksityisen avaimen sekä palvelimen kirjautumistiedot turvallisesti GitHub-repositorioni Actions Secrets -asetuksiin. Näin CI/CD-putki pystyy jatkossa ottamaan automaattisesti yhteyden palvelimeeni ja päivittämään Docker-kontit uusimpaan versioon.

### 4. Automaattinen CI/CD-putki (GitHub Actions)

Viimeistelin infrastruktuurin luomalla automaattisen julkaisuputken (`.github/workflows/deploy.yml`). Putki automatisoi sovelluksen päivityksen ja varmistaa, että palvelimella pyörii aina koodin uusin versio.

Putki koostuu seuraavista vaiheista:

- **Checkout:** Haetaan uusin koodi repositoriosta.

- **SCP Transfer:** Kopioidaan projektin tiedostot (mukaan lukien Docker-konfiguraatiot) suojatusti palvelimelle.

- **SSH Execution:** GitHub Actions ottaa SSH-yhteyden palvelimelle ja suorittaa seuraavat vaiheet:

  - Vie ympäristömuuttujat GitHub Secrets -salaisuuksista shell-ympäristöön ja kirjoittaa tarvittavat `.env`-tiedostot frontendille ja backendille.
  - Ajaa `docker compose down` sammuttaakseen vanhat kontit.
  - Rakentaa frontendin uudelleen ilman välimuistia (`docker compose build --no-cache frontend`) varmistaakseen ajantasaisen buildin.
  - Käynnistää sovelluksen taustalle (`docker compose up -d`).
  - Ajaa Robot Framework -end-to-end -testit erillisessä kontissa (`docker compose --profile e2e up robot --build --abort-on-container-exit`).
  - Siivoaa vanhat Docker-imaget (`docker image prune -f`) levytilan säästämiseksi.

Tämä toetuttaa automaattisen kehityssyklin: kun pushaan koodia `main`-haaraan, muutokset näkyvät palvelimella (IP: 64.227.70.95) muutamassa minuutissa ilman manuaalisia toimenpiteitä.

**Sovelluksen konttiarkkitehtuuri (Docker Compose)**

Projektin infra koostuu kolmesta toisistaan eristetystä kontista, jotka keskustelevat keskenään Dockerin sisäisessä verkossa:

- **Frontend (Nginx + React):** Tarjoilee staattiset tiedostot portissa 80.
- **Backend (Spring Boot):** Suorittaa liiketoimintalogiikan portissa 8080.
- **Database (PostgreSQL):** Tallentaa datan portissa 5432 (eristetty vain backendin käyttöön).

Infrastruktuuri on automatisoitu GitHub Actions -pohjaisella CI/CD-putkella, joka rakentaa ja testaa koko konttiympäristön ennen julkaisua.

---

## Testauksen jakautuminen

Päätin eriyttää testit kahteen tasoon niiden luonteen ja vaatimusten mukaan:

### Backend-testit (GitHub Actions)

Maven-pohjaiset JUnit-testit on automatisoitu osaksi CI/CD-putkea. Ne ajetaan `ubuntu-latest`-ympäristössä aina ennen deploy-vaihetta.

### End-to-End -testaus (Robot Framework)

Alun perin tavoitteena oli ajaa kaikki E2E-testit automaattisesti osana GitHub Actions -CI/CD-putkea. Käytännössä tämä osoittautui kuitenkin haastavaksi: Robot Framework toimi ongelmitta lokaalisti, mutta GitHub Actions -ympäristössä Docker-konttien kanssa ilmeni verkkoyhteysongelmia. Authentication-testi meni läpi, mutta muut testit epäonnistuivat. Vaikka ongelman tarkkaa syytä ei saatu selvitettyä ajalla, CI/CD-putki itsessään toimii ja näyttää testien lokit.

Tämän vuoksi päätin siirtää end-to-end -testauksen ajettavaksi **paikallisessa kehitysympäristössä**. Testit ajetaan suoraan tuotantopalvelinta vasten, mikä varmistaa sovelluksen toimivuuden ennen muutosten mergaamista.

Testit on jaettu neljään tiedostoon selkeyden ja ylläpidettävyyden vuoksi:

- **login_tests.robot**: Varmistaa kriittisimmän toiminnon eli Auth0-kirjautumisen. Testi syöttää testitunnukset ja tarkistaa onnistuneen uudelleenohjauksen hallintapaneeliin.
- **filter_tests.robot**: Testaa työtehtävien hakua ja tekstipohjaista suodatusta sekä tulosten dynaamista päivitystä.
- **category_filter_tests.robot**: Keskittyy suodattimiin, kuten kategorioiden valintaan, hintahaarukkaan ja kaupunkipohjaiseen hakuun.
- **map_tests.robot**: Testaa Google Maps -karttanäkymän latautumista sekä backendistä haettujen koordinaattien näyttämistä kartalla klustereina.

Kaikki testit voidaan ajaa paikallisesti yhdellä komennolla:

```bash
robot --outputdir results e2e-tests/
```
<img width="901" height="672" alt="testsPassed" src="https://github.com/user-attachments/assets/43dab37d-99aa-4923-94ad-549619621aea" />
<img width="1570" height="1493" alt="pullRequest" src="https://github.com/user-attachments/assets/34d030e4-6190-4a6c-b5ae-03f91e4bb3a4" />


## Poikkeamat alkuperäisestä suunnitelmasta

Alkuperäinen tavoite oli ajaa Robot Framework -testit osana CI/CD-putkea Docker-kontissa. 
Tämä ei kuitenkaan onnistunut käytännössä seuraavista syistä:

- Verkkoyhteysongelmat GitHub Actionsin ja Docker-konttien välillä
- Proxy / porttien altistusongelmat
- Ajan rajallisuus

Tämän vuoksi päädyin ratkaisuun:
- Backend-testit → CI/CD:ssä
- E2E-testit → paikallisesti (Ne ovat silti katsottavissa putken lokista)

Tämä kompromissi mahdollistaa edelleen luotettavan testauksen, mutta ei täysin automatisoitua pipelinea.

## Mitä opin

Tämä projekti oli todella opettava kokonaisuus, vaikka se ei edennyt ongelmitta. Suurin oppini deep dive, kuinka sovellus saadaan pysymään pystyssä ja miten sen laatua valvotaan itse rakennetussa tuotantoympäristössä.

Aluksi ajattelin, että CI/CD-putki on vain sarja komentoja, jotka ajetaan automaattisesti. Projektin edetessä ymmärsin, että se on jatkuvaa tasapainoilua infran ja sovelluksen välillä. Opin, miten kriittistä on, että kehitysympäristö ja tuotantoympäristö vastaavat toisiaan.

Ehkä arvokkain oivallus tuli Robot Frameworkin ja GitHub Actionsin integraation haasteiden kautta. Opin, että pilviympäristöissä (kuten GitHubin runnerit) verkkoliikenne, porttien ohjaukset ja headless-selainten käyttäytyminen poikkeavat merkittävästi lokaalista ympäristöstä. Vaikka en saanut aivan jokaista testiä vihreäksi automaattisessa putkessa, opin analysoimaan lokitiedostoja ja ymmärtämään, missä kohtaa "ketju katkeaa". Strateginen päätös siirtää osa testeistä lokaaliin ajoon opetti minulle priorisointia: joskus on tärkeämpää saada toimiva julkaisuputki pystyyn kuin hioa täydellistä automaatiota deadlinen kustannuksella.

Valmiiden palveluiden, kuten Renderin, käyttämisen sijaan itse pystytetty Linux-palvelin opetti minulle valtavasti palvelinhallinnasta. Tämä antoi minulle itsevarmuutta hallita koko sovelluksen elinkaarta ja itsevarmuutta työelämään docker kikkailuihin ja custom palvelimiin.

## Jatkokehitys

Vaikka sovellus on nyt tuotantovalmis ja CI/CD-putki toiminnassa, näen useita kehityskohteita jatkoa ajatellen:

- E2E-testauksen täysi automaatio: Putken viimeistely siten, että Robot Framework -testit ajetaan täysin integroituna GitHub Actionsissa Docker-verkko-ongelmien ratkaisemisen jälkeen.
- Testikattavuuden laajentaminen: Nykyinen testaus on luonteeltaan tekninen demo (Proof of Concept). Jatkossa tarvittaisiin kattava testaussuunnitelma, joka kattaa kaikki reunatapaukset ja monimutkaisemmat käyttäjäpolut.
- CI/CD-putken optimointi: Build-aikojen lyhentäminen hyödyntämällä tehokkaammin Dockerin monivaiheisia rakennusvaiheita (Multi-stage builds) ja välimuistia (Cache layers).
- Monitorointi ja logitus: Palvelinympäristön varustaminen reaaliaikaisella monitoroinnilla, jotta infran tilaa voidaan seurata tarkemmin.

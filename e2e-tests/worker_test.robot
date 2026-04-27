*** Settings ***
Documentation    End-to-End tests for the Gig-Based Job Platform using Playwright.
Library          Browser

*** Variables ***
${FRONTEND_URL}    https://tuomasleinonen.store
${TEST_USER}       seminaari.testi@testi.fi
${TEST_PASS}       Testi123!

*** Test Cases ***
Etusivu latautuu oikein
    [Documentation]    Tarkistaa, että React-sovellus aukeaa.
    New Browser    browser=chromium    headless=True
    New Context    viewport={'width': 1920, 'height': 1080}
    New Page       ${FRONTEND_URL}
    
    Get Text       h1    contains    Saa enemmän aikaan
    Take Screenshot    filename=1_etusivu

Testikayttajan sisaankirjautuminen Auth0 kautta
    [Documentation]    Testaa oikean testikäyttäjän kirjautumisen sovellukseen.
    Click          text="Kirjaudu"
    
    Wait For Condition    Url    contains    auth0.com
    
    Fill Text      input[name="username"]    ${TEST_USER}
    Fill Text      input[name="password"]    ${TEST_PASS}
    
    Click          button[value="default"]
    
    Wait For Elements State    text="Kirjaudu ulos"    visible    timeout=20s
    Take Screenshot    filename=2_kirjautunut_sisaan

Tyoilmoitukset valilehti ja suodatus
    [Documentation]    Siirtyy työilmoitukset-sivulle ja käyttää hakua.
    # Siirrytään oikealle välilehdelle yläpalkista
    Click          text="Työilmoitukset"
    
    # Varmistetaan, että sivu latautui (kuvassasi iso "Selaa tehtäviä" -otsikko)
    Wait For Elements State    h1:has-text("Selaa tehtäviä")    visible    timeout=10s
    
    # Testataan suodattimia
    Fill Text      css=[placeholder="Etsi otsikosta tai kuvauksesta..."]    Siivousapua
    Click          text="Cleaning"
    Click          button:has-text("Hae tehtäviä")
    
    Sleep          2s
    Take Screenshot    filename=3_haku_suoritettu
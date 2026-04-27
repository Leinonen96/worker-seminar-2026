*** Settings ***
Documentation    End-to-End tests for the Gig-Based Job Platform using Playwright.
Library          Browser

*** Variables ***
${FRONTEND_URL}    https://tuomasleinonen.store
${TEST_USER}       seminaari.testi@testi.fi
${TEST_PASS}       Testi123!

*** Test Cases ***
Suorita E2E Smoke Test
    [Documentation]    Käy läpi koko pääpolun: etusivu, kirjautuminen ja suodatus.
    
    New Browser    browser=chromium    headless=True
    New Context    viewport={'width': 1920, 'height': 1080}
    New Page       ${FRONTEND_URL}
    
    # 1. ETUSIVU
    # Odotetaan, että pääotsikko ilmestyy
    Wait For Elements State    css=h1    visible    timeout=15s
    Take Screenshot    filename=1_etusivu
    
    # 2. KIRJAUTUMINEN (Auth0-polku)
    Click          role=button[name="Kirjaudu"]
    
    Wait For Condition    Url    contains    auth0.com    timeout=15s
    
    # Syötetään tunnukset
    Fill Text      role=textbox[name="Email address"]    ${TEST_USER}
    Fill Text      role=textbox[name="Password"]         ${TEST_PASS}
    
    # Painetaan Continue-nappia
    Click          role=button[name="Continue"]
    
    # 3. KIRJAUTUMISEN VARMISTUS
    # Odotetaan, että profiililinkki ilmestyy
    Wait For Elements State    role=link[name="Profiili"]    visible    timeout=20s
    Take Screenshot    filename=2_kirjautunut_sisaan
    
    # 4. TYÖILMOITUKSET JA HAKU
    Click          role=link[name="Työilmoitukset"]
    
    # Odotetaan haku-nappia
    Wait For Elements State    role=button[name="search Hae tehtäviä"]    visible    timeout=15s
    
    # Syötetään hakusana placeholderilla
    Fill Text      css=[placeholder="Etsi otsikosta tai kuvauksesta..."]    Siivousapua
    
    # Suoritetaan haku
    Click          role=button[name="search Hae tehtäviä"]
    
    Sleep          2s
    Take Screenshot    filename=3_haku_suoritettu
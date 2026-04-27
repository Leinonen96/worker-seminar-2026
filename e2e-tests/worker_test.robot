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
    
    # Käynnistetään selain
    New Browser    browser=chromium    headless=True
    New Context    viewport={'width': 1920, 'height': 1080}
    
    # 1. ODOTETAAN PALVELIMEN HERÄÄMISTÄ
    # Palvelimella buildin jälkeen sivu voi olla hetken hidas.
    # Go To -komennon jälkeen odotetaan, että sivu oikeasti latautuu.
    Go To          ${FRONTEND_URL}
    
    # Nostetaan ensimmäisen latauksen timeoutia 30 sekuntiin palvelimen hitauden varalta
    Wait For Elements State    css=h1    visible    timeout=30s
    Take Screenshot    filename=1_etusivu
    
    # 2. KIRJAUTUMINEN (Auth0-polku)
    Click          role=button[name="Kirjaudu"]
    
    # Auth0 saattaa olla hidas, joten odotetaan, että URL sisältää auth0.com -osan ennen kuin jatketaan
    Wait For Condition    Url    contains    auth0.com    timeout=30s
    
    Fill Text      role=textbox[name="Email address"]    ${TEST_USER}
    Fill Text      role=textbox[name="Password"]         ${TEST_PASS}
    
    Click          role=button[name="Continue"]
    
    # 3. KIRJAUTUMISEN VARMISTUS
    Wait For Elements State    role=link[name="Profiili"]    visible    timeout=30s
    Take Screenshot    filename=2_kirjautunut_sisaan
    
    # 4. TYÖILMOITUKSET JA HAKU
    Click          role=link[name="Työilmoitukset"]
    
    Wait For Elements State    role=button[name="search Hae tehtäviä"]    visible    timeout=30s
    
    Fill Text      css=[placeholder="Etsi otsikosta tai kuvauksesta..."]    Siivousapua
    Click          role=button[name="search Hae tehtäviä"]
    
    Sleep          2s
    Take Screenshot    filename=3_haku_suoritettu
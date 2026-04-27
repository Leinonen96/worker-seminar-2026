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
    # ignoreHTTPSErrors=True on kriittinen, kun soitellaan "itse itselle" palvelimen sisällä
    New Context    viewport={'width': 1920, 'height': 1080}    ignoreHTTPSErrors=True
    
    # 1. AVATAAN SIVU
    New Page       ${FRONTEND_URL}
    
    # Odotetaan verkkoa
    Wait For Load State    networkidle    timeout=30s
    
    # Käytetään uutta "heading"-lokaattoria
    Wait For Elements State    role=heading[name="Saa enemmän aikaan"]    visible    timeout=30s
    Take Screenshot    filename=1_etusivu
    
    # 2. KIRJAUTUMINEN
    Click          role=button[name="Kirjaudu"]
    Wait For Condition    Url    contains    auth0.com    timeout=30s
    
    Fill Text      role=textbox[name="Email address"]    ${TEST_USER}
    Fill Text      role=textbox[name="Password"]         ${TEST_PASS}
    Click          role=button[name="Continue"]
    
    # 3. KIRJAUTUMISEN VARMISTUS
    # Tässä vaiheessa Auth0 ohjaa takaisin tuomasleinonen.storeen, 
    Wait For Elements State    role=link[name="Profiili"]    visible    timeout=30s
    Take Screenshot    filename=2_kirjautunut_sisaan
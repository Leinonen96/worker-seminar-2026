*** Settings ***
Documentation    End-to-End tests for the Gig-Based Job Platform using Playwright.
Library          Browser

*** Variables ***
# Kokeillaan ensin julkista URLia, mutta vikasietoisemmin
${FRONTEND_URL}    https://tuomasleinonen.store
${TEST_USER}       seminaari.testi@testi.fi
${TEST_PASS}       Testi123!

*** Test Cases ***
Suorita E2E Smoke Test
    [Documentation]    Käy läpi koko pääpolun: etusivu, kirjautuminen ja suodatus.
    
    New Browser    browser=chromium    headless=True
    # Asetetaan ignore_https_errors siltä varalta, että palvelimen sisäinen verkko herjaa sertifikaatista
    New Context    viewport={'width': 1920, 'height': 1080}    ignoreHTTPSErrors=True
    
    # 1. AVATAAN SIVU
    New Page       ${FRONTEND_URL}
    
    # Odotetaan ensin, että jokin h1-elementti ilmestyy (oli siinä mitä tekstiä tahansa)
    Wait For Elements State    css=h1    visible    timeout=40s
    
    # Otetaan heti screenshot – jos tämä feilaa, näemme mitä siellä oikeasti on
    Take Screenshot    filename=1_debug_lataus
    
    # Tehdään osittainen tekstihaku (ilman lainausmerkkejä)
    Wait For Elements State    text=Saa enemmän aikaan    visible    timeout=10s
    
    # 2. KIRJAUTUMINEN
    Click          role=button[name="Kirjaudu"]
    Wait For Condition    Url    contains    auth0.com    timeout=30s
    
    Fill Text      role=textbox[name="Email address"]    ${TEST_USER}
    Fill Text      role=textbox[name="Password"]         ${TEST_PASS}
    Click          role=button[name="Continue"]
    
    # 3. KIRJAUTUMISEN VARMISTUS
    Wait For Elements State    role=link[name="Profiili"]    visible    timeout=30s
    Take Screenshot    filename=2_kirjautunut_sisaan
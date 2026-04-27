*** Settings ***
Documentation     End-to-End tests for the Gig-Based Job Platform using Playwright.
Library           Browser

*** Variables ***
${FRONTEND_URL}    https://tuomasleinonen.store
${TEST_USER}       seminaari.testi@testi.fi
${TEST_PASS}       Testi123!

*** Test Cases ***
Suorita E2E Smoke Test
    [Documentation]    Käy läpi koko pääpolun: etusivu, kirjautuminen ja suodatus.
    
    # Käynnistys
    New Browser    browser=chromium    headless=True
    # ignoreHTTPSErrors on kriittinen palvelimen sisäisessä verkossa
    New Context    viewport={'width': 1920, 'height': 1080}    ignoreHTTPSErrors=True
    
    # 1. AVATAAN SIVU
    New Page       ${FRONTEND_URL}
    
    # Odotetaan verkkoliikenteen rauhoittumista
    Wait For Load State    networkidle    timeout=30s
    
    # DEBUG-LOGIIKKA: Yritetään etsiä otsikkoa, ja jos se feilaa, dumpataan HTML lokiin
    ${status}=    Run Keyword And Return Status    
    ...    Wait For Elements State    role=heading[name="Saa enemmän aikaan"]    visible    timeout=30s
    
    IF    not ${status}
        # Klikataan virheilmoitus auki, jos React Error Boundary on näkyvissä
        ${error_exists}=    Run Keyword And Return Status    Page Should Contain    Something went wrong!
        IF    ${error_exists}
            Click    text="Show Error"
            ${actual_error}=    Get Text    pre    # Virheet ovat usein <pre> tägeissä
            Log    VARSINAINEN REACT VIRHE: ${actual_error}    level=ERROR
        END
        
        ${source}=    Get Page Source
        Log    HTML SISÄLTÖ EPÄONNISTUESSA: ${source}    level=ERROR
        Take Screenshot    filename=fail_debug_source
        Fail    React-sovellus kaatui käynnistyksessä. Katso virhe ylhäältä.
    END

    Take Screenshot    filename=1_etusivu

    # 2. KIRJAUTUMINEN (Auth0)
    Click          role=button[name="Kirjaudu"]
    Wait For Condition    Url    contains    auth0.com    timeout=30s
    
    Fill Text      role=textbox[name="Email address"]    ${TEST_USER}
    Fill Text      role=textbox[name="Password"]         ${TEST_PASS}
    Click          role=button[name="Continue"]
    
    # 3. KIRJAUTUMISEN VARMISTUS
    # Auth0 ohjaa takaisin, odotetaan profiili-linkkiä
    Wait For Elements State    role=link[name="Profiili"]    visible    timeout=30s
    Take Screenshot    filename=2_kirjautunut_sisaan
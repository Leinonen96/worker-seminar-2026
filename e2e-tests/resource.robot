*** Settings ***
Library     Browser

*** Variables ***
# Oletusarvot paikallista ajoa varten (videota varten headless=False)
${BASE_URL}       https://tuomasleinonen.store
${HEADLESS}       False
${TEST_USER}      seminaari.testi@testi.fi
${TEST_PASS}      Testi123!

*** Keywords ***
Avaa Sovellus
    # Käytetään muuttujaa ${HEADLESS}, jotta CI-putki voi ylikirjoittaa sen
    New Browser     browser=chromium    headless=${HEADLESS}
    New Context     viewport={'width': 1920, 'height': 1080}    ignoreHTTPSErrors=True
    
    # Käytetään muuttujaa ${BASE_URL}, jotta CI voi testata lokaalia Docker-konttia
    New Page        ${BASE_URL}
    Wait For Elements State    css=h1    visible    timeout=30s
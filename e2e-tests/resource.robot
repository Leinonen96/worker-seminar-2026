*** Settings ***
Library     Browser

*** Variables ***
${BASE_URL}       https://tuomasleinonen.store
${HEADLESS}       ${True} 
${TEST_USER}      seminaari.testi@testi.fi
${TEST_PASS}      Testi123!

*** Keywords ***
Avaa Sovellus
    New Browser     browser=chromium    headless=${HEADLESS}
    New Context     viewport={'width': 1920, 'height': 1080}    ignoreHTTPSErrors=True
    
    New Page        ${BASE_URL}
    Wait For Elements State    css=h1    visible    timeout=30s
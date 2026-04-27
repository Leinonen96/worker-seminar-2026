*** Settings ***
Library    Browser

*** Variables ***
${BASE_URL}       https://tuomasleinonen.store
${TEST_USER}      seminaari.testi@testi.fi
${TEST_PASS}      Testi123!

*** Keywords ***
Avaa Sovellus
    # Palvelinta testatessa headless=False on kiva, jos haluat katsella,
    # mutta raporttia varten headless=True on nopeampi.
    New Browser    browser=chromium    headless=False
    New Context    viewport={'width': 1920, 'height': 1080}    ignoreHTTPSErrors=True
    New Page       ${BASE_URL}
    # Odotetaan, että sivu todella latautuu palvelimelta
    Wait For Elements State    css=h1    visible    timeout=30s
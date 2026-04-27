*** Settings ***
Resource    resource.robot
Test Setup  Avaa Sovellus

*** Test Cases ***
Kirjautuminen Ja Uloskirjautuminen Palvelimella
    [Documentation]    Testataan oikeaa live-ympäristöä.
    
    Take Screenshot    filename=live_0_alkutila
    
    # 1. Klikkaa Kirjaudu
    Click    role=button[name="Kirjaudu"]
    
    # 2. Auth0-kirjautuminen
    Wait For Condition    Url    contains    auth0.com    timeout=30s
    Fill Text    role=textbox[name="Email address"]    ${TEST_USER}
    Fill Text    role=textbox[name="Password"]         ${TEST_PASS}
    Click    role=button[name="Continue"]
    
    # 3. Varmista sisäänkirjautuminen
    Wait For Elements State    role=button[name="Kirjaudu ulos"]    visible    timeout=30s
    Take Screenshot    filename=live_1_kirjautunut
    
    # 4. Uloskirjautuminen
    Click    role=button[name="Kirjaudu ulos"]
    
    # 5. Loppuvarmistus
    Wait For Elements State    role=button[name="Kirjaudu"]    visible    timeout=15s
    Take Screenshot    filename=live_2_uloskirjautunut
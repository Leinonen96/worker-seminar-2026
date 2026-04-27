*** Settings ***
Resource    resource.robot
Test Setup  Avaa Tehtavasivu

*** Keywords ***
Avaa Tehtavasivu
    New Browser    browser=chromium    headless=ture
    New Context    viewport={'width': 1920, 'height': 1080}    ignoreHTTPSErrors=True
    New Page       https://tuomasleinonen.store/worker/tasks
    Wait For Elements State    css=h1    visible    timeout=20s

*** Test Cases ***
Suodata Tehtavia Kategoriolla
    [Documentation]    Testataan, että kategorioiden valitseminen ja sijainnin syöttö toimivat.
    
    # 1. KATEGORIOIDEN VALINTA
    Wait For Elements State    text="Garden"    visible    timeout=15s
    Click    text="Garden"
    Click    text="Moving"
    Click    text="Other"

    # 2. HINTASUODATTIMET 
    Fill Text    css=[placeholder="Min €"]    50
    Fill Text    css=[placeholder="Max €"]    200
    
    # 3. SIJAINTI
    Type Text     css=[placeholder="Kaupunki tai osoite..."]    tampere
    Press Keys    css=[placeholder="Kaupunki tai osoite..."]    Enter
    Take Screenshot    filename=kategoria_1_valittu

    # 4. HAKU
    Click    role=button[name*="Hae tehtäviä"]
    
    # 5. TULOSTEN VARMISTUS
    Wait For Elements State    text="Löytyi"    visible    timeout=15s
    
    # Skrollaus ensimmäiseen korttiin
    Scroll To Element    css=h3.font-semibold >> nth=0
    
    Sleep    1s    
    Take Screenshot    filename=kategoria_2_tulokset    fullPage=True
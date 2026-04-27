*** Settings ***
Resource      resource.robot
Test Setup    Avaa Tehtavasivu

*** Keywords ***
Avaa Tehtavasivu
    New Browser    browser=chromium    headless=false
    New Context    viewport={'width': 1920, 'height': 1080}    ignoreHTTPSErrors=True
    New Page       https://tuomasleinonen.store/worker/tasks
    Wait For Elements State    css=h1    visible    timeout=20s

*** Test Cases ***
Suodata Tehtavia Role Tyylilla
    [Documentation]    E2E-testi työilmoitusten hakemiselle ja suodattamiselle.
    
    # 1. HAKUSANA
    Wait For Elements State    role=textbox[name*="Etsi otsikosta"]    visible    timeout=15s
    Fill Text    role=textbox[name*="Etsi otsikosta"]    siivoa
    
    # 2. HINTASUODATTIMET 
    Fill Text    css=[placeholder="Min €"]    50
    Fill Text    css=[placeholder="Max €"]    200
    
    # 3. SIJAINTI
    Fill Text    role=textbox[name*="Kaupunki"]    helsinki
    
    # 4. HAKUNAPPI
    Click    role=button[name*="Hae tehtäviä"]
    
    # 5. TULOSTEN VARMISTUS (Vaihdettu olemassa olevaan kohteeseen)
    Wait For Elements State    text="Siivoa parvi #6"    visible    timeout=15s
    
    # Skrollataan kohteeseen ja otetaan kuva
    Scroll To Element    text="Siivoa parvi #6"
    Sleep    1s    
    Take Screenshot    filename=filter_vaihe_2_valmis    fullPage=True
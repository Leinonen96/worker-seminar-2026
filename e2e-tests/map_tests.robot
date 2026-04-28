*** Settings ***
Resource    resource.robot
Test Setup  Avaa Tehtavasivu

*** Keywords ***
Avaa Tehtavasivu
    New Browser    browser=chromium    headless=true
    New Context    viewport={'width': 1920, 'height': 1080}    ignoreHTTPSErrors=True
    New Page       https://tuomasleinonen.store/worker/tasks
    Wait For Elements State    css=h1    visible    timeout=20s

*** Test Cases ***
Tarkista Karttanakyma Latautuu
    [Documentation]    Varmistetaan, että karttanäkymä aukeaa (Google Maps UI latautuu).
    
    # 1. KARTTANÄKYMÄÄN SIIRTYMINEN
    Wait For Elements State    text="Kartta"    visible
    Click    text="Kartta"
    
    # 2. SKROLLAUS KARTTAAN
    Wait For Elements State    text="tehtävää kartalla"    visible    timeout=15s
    Scroll To Element          text="tehtävää kartalla"
    
    # 3. KARTAN LATAUTUMISEN VARMISTUS (Sinun ideasi!)
    # Varmistetaan, että Google Mapsin oma kokoruudun painike on piirtynyt.
    Wait For Elements State    css=button[title="Toggle fullscreen view"] >> nth=0    visible    timeout=15s
    
    Sleep    2s    
    Take Screenshot    filename=map_ladattu_onnistuneesti
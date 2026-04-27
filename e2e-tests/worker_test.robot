*** Settings *** 
Documentation    End-to-End tests for the Gig-Based Job Platform using Playwright.
Library          Browser

*** Variables ***
${FRONTEND_URL}    https://tuomasleinonen.store

*** Test Cases ***
Verify Homepage Loads Successfully
    [Documentation]    Checks that the frontend React application starts and displays the main page.
    New Browser    browser=chromium    headless=True
    New Context    viewport={'width': 1920, 'height': 1080}
    New Page       ${FRONTEND_URL}
    
    # If the page shows an error message, click "Show Error" to see the details
    ${status}=    Run Keyword And Return Status    Page Should Contain    Something went wrong!
    IF    ${status}
        Click    text="Show Error"
        Take Screenshot    fullPage=True
        ${error_details}=    Get Text    pre    # Error boundaries often display the error in a <pre> tag
        Log    Actual React Error: ${error_details}
    END
    
    # Wait for the normal homepage to load
    Wait For Elements State    text="Luo tehtävä"    visible    timeout=15s
    Take Screenshot
*** Settings ***
Documentation    End-to-End tests for the Gig-Based Job Platform using Playwright.
Library          Browser

*** Variables ***
# Internal Docker network address for the frontend (port 80 inside the container network)
${FRONTEND_URL}    https://tuomasleinonen.store

*** Test Cases ***
Verify Homepage Loads Successfully
    [Documentation]    Checks that the frontend React application starts and displays the main page.
    
    # Initialize the Playwright browser in headless mode (no UI)
    New Browser    browser=chromium    headless=True
    
    # Create a new browser context
    New Context    viewport={'width': 1920, 'height': 1080}
    
    # Navigate to the frontend container
    New Page       ${FRONTEND_URL}
    
    # Verify that the page successfully loads and contains the expected text
    # (Update "Luo tehtävä" if your UI text is different)
    Get Text       body    contains    Luo tehtävä
    
    # Take a screenshot for the test report
    Take Screenshot
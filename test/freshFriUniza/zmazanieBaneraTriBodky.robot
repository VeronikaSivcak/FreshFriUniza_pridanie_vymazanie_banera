# Created by Simona Tothova at 1. 1. 2025

*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${BASE URL}                 https://fresh.fri.uniza.sk
${LOGIN URL}                ${BASE URL}/login

# Input data - prihlasovacie udaje, popis banera, ktory chceme vymazat, nazvy screenshotov
${USERNAME}                 hrkut
${PASSWORD}                 fricka
${EXPECTED_TEXT}            Server
${SCREENSHOT_NAME_1}        t4_rozkliknute_menu.png
${SCREENSHOT_NAME_2}        t4_formular.png
${SCREENSHOT_NAME_3}        t4_uspech.png

# Locators - prihlasenie, odhlasenie
${USERNAME_FIELD}        xpath=//input[@type='text']
${PASSWORD_FIELD}        id=password
${LOGIN_BUTTON}          xpath=//button[@type='submit']
${FRI_LOGO}              xpath=//a[@href='/' and .//img[@alt='Logo Fri']]
${LOGOUT_BUTTON}         xpath=//*[@id="app"]/div/div[6]/div[2]/div/span/span/a/span/span

# Locators - Obsah, Banery, BANNERS_BODY (zoznam banerov - na overenie, ci je zoznam nacitany)
${DASHBOARD_CONTENT}           xpath=//div[@class='menu-group-container' and .//div[@class='group-text' and text()='Obsah']]
${BANNERS_SECTION}             xpath=//a[@href='/cms/banners' and text()='Banery']
${BANNERS_BODY}                xpath=//tbody[@class='ant-table-tbody']

# Locators - td element (predstavuje baner), ktory obsahuje popis Server (baner, ktory vymazavame), tlacidlo na editovanie banera s popisom Server
${TD_ELEMENT}                  xpath=//td[@class='ant-table-cell ant-table-cell-ellipsis' and text()='${EXPECTED_TEXT}']
${EDIT_BUTTON_XPATH}           xpath=//td[@class='ant-table-cell ant-table-cell-ellipsis' and text()='${EXPECTED_TEXT}']/ancestor::tr//span[@aria-label='edit']/ancestor::button

# Locators - menu (tlacidlo tri bodky), tlacidlo na vymazanie banera
${THREE_DOTS_BUTTON}           xpath=//div[@class='right-controls-container']//button
${DELETE_BUTTON}               xpath=//div[text()='Vymazať']

# Locators - tlacidlo na potvrdenie vymazania banera, sprava o uspesnom vymazani banera
${YES_BUTTON}                  xpath=//button[@type='button' and .//span[text()='Áno']]
${SUCCESS_MESSAGE}             xpath=//div[contains(@class, 'ant-notification-notice-success')]

*** Keywords ***
Open Browser And Navigate To Login
    Open Browser    ${LOGIN URL}    Chrome
    Maximize Browser Window

Login As Admin
    Wait Until Element Is Visible    ${USERNAME_FIELD}    timeout=10s
    Input Text    ${USERNAME_FIELD}    ${USERNAME}
    Input Text    ${PASSWORD_FIELD}    ${PASSWORD}
    Click Button    ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${DASHBOARD_CONTENT}    timeout=10s

# Presun na sekciu banerov
Navigate To Banners Section
    Click Element    ${DASHBOARD_CONTENT}
    Wait Until Element Is Visible    ${BANNERS_SECTION}    timeout=10s
    Click Element    ${BANNERS_SECTION}
    Wait Until Element Is Visible   ${BANNERS_BODY}

# Najdenie banera s popisom Server a jeho vymazanie po kliknuti na editovanie, rozbalenie menu a po klkiknuti na tlacidlo vymazat
Try To Find Banner And Delete It
    ${status}=  Run Keyword And Return Status    Get WebElement    ${TD_ELEMENT}
    # Ak sa nasiel baner, ktory obsahuje popis ${EXPECTED_TEXT}, potrebujeme najst spravne tlacidlo editovat
    IF   ${status} == True
        ${edit_button}=    Get WebElement  ${EDIT_BUTTON_XPATH}
        Click Button    ${edit_button}
        Wait Until Element Is Visible    ${THREE_DOTS_BUTTON}    timeout=10s
        Sleep   2s
        Click Button    ${THREE_DOTS_BUTTON}
        Wait Until Element Is Visible    ${DELETE_BUTTON}    timeout=10s
        Sleep   2s
        Capture Page Screenshot    ${SCREENSHOT_NAME_1}
        Click Element    ${DELETE_BUTTON}
        Wait Until Element Is Visible    ${YES_BUTTON}    timeout=10s
        Capture Page Screenshot    ${SCREENSHOT_NAME_2}
        Sleep   2s
        Click Button    ${YES_BUTTON}
        Wait Until Element Is Visible    ${SUCCESS_MESSAGE}    timeout=10s
        Capture Page Screenshot    ${SCREENSHOT_NAME_3}
        Sleep   1s
    END

# Overenie, ze sa baner uz nenachadza v zozname banerov
Verify If Banner Is Not In Banner List
    Page Should Not Contain Element     ${TD_ELEMENT}

Log Out
    Click Element    ${FRI_LOGO}
    Wait Until Element Is Visible    ${LOGOUT_BUTTON}    timeout=10s
    Click Element    ${LOGOUT_BUTTON}

*** Test Cases ***
Remove Banner If Server Exists
    [Documentation]    This test case should test deleting Server banner using edit, menu and delete button on fresh.fri.uniza.sk
    [Tags]  zmazanieBaneraIkonaKos

    [Setup]    Open Browser And Navigate To Login

    Login As Admin
    Navigate To Banners Section
    Try To Find Banner And Delete It
    Verify If Banner Is Not In Banner List
    Log Out

    [Teardown]    Close Browser

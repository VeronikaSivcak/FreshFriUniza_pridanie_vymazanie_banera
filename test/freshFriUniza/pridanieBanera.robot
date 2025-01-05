# Created by Simona Tothova at 29. 12. 2024

*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${BASE URL}                 https://fresh.fri.uniza.sk
${LOGIN URL}                ${BASE URL}/login

# Input data - prihlasovacie udaje, udaje na vyplnenie formulara, nazvy screenshotov
${USERNAME}                 hrkut
${PASSWORD}                 fricka
${BANNER_DESCRIPTION}       Server
${BANNER_URL}               https://frios2.fri.uniza.sk/
# pri spusteni testu inym testerom, potrebna zmena absolutnej cesty k obrazku
${BANNER_IMAGE_PATH}        C:/Users/veron/PycharmProjects/Testy_Tothova/PythonProject2/test/resources/server_banner_image.png
${SCREENSHOT_NAME_1}        t1_vyznacene_polia.png
${SCREENSHOT_NAME_2}        t1_vyplneny_formular.png
${SCREENSHOT_NAME_3}        t1_uspech.png

# Locators - prihlasenie, odhlasenie
${USERNAME_FIELD}        xpath=//input[@type='text']
${PASSWORD_FIELD}        id=password
${LOGIN_BUTTON}          xpath=//button[@type='submit']
${FRI_LOGO}              xpath=//a[@href='/' and .//img[@alt='Logo Fri']]
${LOGOUT_BUTTON}         xpath=//*[@id="app"]/div/div[6]/div[2]/div/span/span/a/span/span

# Locators - Obsah, Banery, tlacidlo na pridanie banera, tlacidlo na ulozenie banera
${DASHBOARD_CONTENT}        xpath=//div[@class='menu-group-container' and .//div[@class='group-text' and text()='Obsah']]
${BANNERS_SECTION}          xpath=//a[@href='/cms/banners' and text()='Banery']
${ADD_BANNER_BUTTON}        xpath=//button[@type='button' and .//span[@class='ant-btn-icon']/span[@aria-label='plus']]
${SAVE_BUTTON}              xpath=//button[@type='submit' and .//span[text()='Uložiť']]

# Locators - Vypisy 'Pole je povinné' pre URL, popis aj obrazok
${REQUIRED_FIELD_ALERT_URL}         xpath=//div[@id='target_url_help']//div[@class='ant-form-item-explain-error' and text()='Pole je povinné']
${REQUIRED_FIELD_ALERT_IMAGE}       xpath=//div[@id='image_object_help']//div[@class='ant-form-item-explain-error' and text()='Pole je povinné']
${REQUIRED_FIELD_ALERT_DESC}        xpath=//div[@id='meta_name_help']//div[@class='ant-form-item-explain-error' and text()='Pole je povinné']

# Locators - Inputy pre obrazok, URL a popis, tlacidlo na zobrazenie banera a sprava o uspesnom ulozeni banera
${UPLOAD_IMAGE_FIELD}       xpath=//span[@class='ant-upload ant-upload-btn' and @role='button']/input[@type='file' and @id='image_object']
${URL_FIELD}                xpath=//input[@id='target_url' and @type='text']
${DESCRIPTION_FIELD}        xpath=//input[@id='meta_name' and @type='text']
${DISPLAY_CHECKBOX}         xpath=//button[@role='switch' and @type='button']
${SUCCESS_MESSAGE}          xpath=//div[contains(@class, 'ant-notification-notice-success')]

# Locator - td element (predstavuje baner), ktory obsahuje popis Server - na overenie, ci bol baner pridany do zoznamu banerov
${TD_ELEMENT}               xpath=//td[@class='ant-table-cell ant-table-cell-ellipsis' and text()='${BANNER_DESCRIPTION}']

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
Navigate To Banner Section
    Click Element    ${DASHBOARD_CONTENT}
    Wait Until Element Is Visible    ${BANNERS_SECTION}    timeout=10s
    Click Element    ${BANNERS_SECTION}
    Wait Until Element Is Visible   ${ADD_BANNER_BUTTON}

# Overenie, ci polia pre obrazok, URL a popis zobrazia vypisy 'Pole je povinné', ak sa do formulara nezadaju ziadne informacie
Add New Banner Without Data
    Click Button    ${ADD_BANNER_BUTTON}
    Wait Until Element Is Visible    ${DESCRIPTION_FIELD}    timeout=10s
    # Potrebne kliknutie na pole, inak by sa vypisy nezobrazili
    Click Element    ${DESCRIPTION_FIELD}
    Sleep   1s
    Wait Until Element Is Visible    ${SAVE_BUTTON}    timeout=10s
    Click Button    ${SAVE_BUTTON}
    Wait Until Element Is Visible    ${REQUIRED_FIELD_ALERT_DESC}    timeout=10s
    Wait Until Element Is Visible    ${REQUIRED_FIELD_ALERT_URL}    timeout=10s
    Wait Until Element Is Visible    ${REQUIRED_FIELD_ALERT_IMAGE}    timeout=10s
    Capture Page Screenshot    ${SCREENSHOT_NAME_1}
    Sleep   2s

# Pridanie banera so spravnymi informaciami, odkliknutie tlacidla Zobrazit a overenie, ci sa zobrazila sprava o uspesnom ulozeni
Add New Banner With Valid Data
    Choose File    ${UPLOAD_IMAGE_FIELD}    ${BANNER_IMAGE_PATH}
    Input Text    ${URL_FIELD}    ${BANNER_URL}
    Input Text    ${DESCRIPTION_FIELD}    ${BANNER_DESCRIPTION}
    Click Button    ${DISPLAY_CHECKBOX}
    Sleep   1s
    Capture Page Screenshot    ${SCREENSHOT_NAME_2}
    Sleep   2s
    Click Button    ${SAVE_BUTTON}
    Wait Until Element Is Visible    ${SUCCESS_MESSAGE}    timeout=10s
    Capture Page Screenshot    ${SCREENSHOT_NAME_3}
    Sleep   1s

# Overenie, ci bol baner pridany do zoznamu banerov po zobrazeni spravy o uspesnom ulozeni
Verify If Banner Is In Banner List
    Page should contain element    ${TD_ELEMENT}

Log Out
    Click Element    ${FRI_LOGO}
    Wait Until Element Is Visible    ${LOGOUT_BUTTON}    timeout=10s
    Click Element    ${LOGOUT_BUTTON}

*** Test Cases ***
Verify Adding New Banner
    [Documentation]    This test case should test adding new banner on fresh.fri.uniza.sk
    [Tags]  pridanieBanera

    [Setup]    Open Browser And Navigate To Login

    Login As Admin
    Navigate To Banner Section
    Add New Banner Without Data
    Add New Banner With Valid Data
    Verify If Banner Is In Banner List
    Log Out

    [Teardown]    Close Browser

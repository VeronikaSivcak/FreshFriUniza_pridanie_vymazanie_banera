# Created by Simona Tothova at 30. 12. 2024

*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${BASE URL}                 https://fresh.fri.uniza.sk
${LOGIN URL}                ${BASE URL}/login

# Input data - prihlasovacie udaje, udaje na vyplnenie formulara (vratane spravnej a nespravnej URL), nazvy screenshotov
${USERNAME}                 hrkut
${PASSWORD}                 fricka
${BANNER_DESCRIPTION}       Server
${BANNER_URL_INCORRECT}     frios2.fri.uniza.sk
${BANNER_URL_CORRECT}       https://frios2.fri.uniza.sk/
# pri spusteni testu inym testerom, potrebna zmena absolutnej cesty k obrazku
${BANNER_IMAGE_PATH}        C:/Users/veron/PycharmProjects/Testy_Tothova/semestralka_pridanie_vymazanie_banera/test/resources/server_banner_image.png
${SCREENSHOT_NAME_1}        t2_vyznacene_pole_URL.png
${SCREENSHOT_NAME_2}        t2_spravne_vyplneny_formular.png
${SCREENSHOT_NAME_3}        t2_uspech.png

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

# Locators - Vypis 'Zadajte platnú URL adresu'
${INCORRECT_FIELD_ALERT_URL}        xpath=//div[@id='target_url_help']//div[@class='ant-form-item-explain-error' and text()='Zadajte platnú URL adresu']

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
Navigate To Banners Section
    Click Element    ${DASHBOARD_CONTENT}
    Wait Until Element Is Visible    ${BANNERS_SECTION}    timeout=10s
    Click Element    ${BANNERS_SECTION}
    Wait Until Element Is Visible   ${ADD_BANNER_BUTTON}

# Vyplnenie nespravnej URL adresy do formulara a overenie, ci sa zobrazi vypis 'Zadajte platnú URL adresu'
Add New Banner With Incorrect URL
    Click Button    ${ADD_BANNER_BUTTON}
    Wait Until Element Is Visible    ${URL_FIELD}    timeout=10s
    Choose File    ${UPLOAD_IMAGE_FIELD}    ${BANNER_IMAGE_PATH}
    Input Text    ${DESCRIPTION_FIELD}    ${BANNER_DESCRIPTION}
    Input Text    ${URL_FIELD}    ${BANNER_URL_INCORRECT}
    Click Button    ${SAVE_BUTTON}
    Wait Until Element Is Visible    ${INCORRECT_FIELD_ALERT_URL}    timeout=10s
    Sleep   2s
    Capture Page Screenshot    ${SCREENSHOT_NAME_1}

# Pridanie banera so spravnou URL, odkliknutie tlacidla Zobrazit a overenie, ci sa zobrazila sprava o uspesnom ulozeni
Add New Banner With Correct URL
    # nefungujuci Clear Element Text - riesenie - https://stackoverflow.com/questions/53518481/robot-framework-clear-element-text-keyword-is-not-working?fbclid=IwZXh0bgNhZW0CMTEAAR3Tb0YlMdh_jptcnjF_kuwT0qVcJ-EdXc0td-EfumCZGxH_vqzrk5MRlCg_aem_BPLJY0i6jK35SDkjVTa_cQ
    Press Keys    ${URL_FIELD}    CTRL+A+DELETE
    Sleep   1s
    Input Text    ${URL_FIELD}    ${BANNER_URL_CORRECT}
    Click Button    ${DISPLAY_CHECKBOX}
    Sleep   2s
    Capture Page Screenshot    ${SCREENSHOT_NAME_2}
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
Verify URL Validation
    [Documentation]    This test case should test URL field functionality in adding new banner form on fresh.fri.uniza.sk
    [Tags]  validaciaURL

    [Setup]    Open Browser And Navigate To Login

    Login As Admin
    Navigate To Banners Section
    Add New Banner With Incorrect URL
    Add New Banner With Correct URL
    Verify If Banner Is In Banner List
    Log Out

    [Teardown]    Close Browser

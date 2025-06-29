*** Settings ***
Library    SeleniumLibrary
Library    DateTime
Library    String

Suite Teardown      Close Browser

*** Variables ***
${URL}           https://www.random.org/calendar-dates/   
${BROWSER}       chrome
${START_DATE}    2024-01-05
${END_DATE}      2025-11-25

*** keywords ***
Date Should Be Between
    [Arguments]    ${date}    ${START_DATE}    ${END_DATE}  
        ${converted_date}=    Convert Date    ${date}          date_format=%Y-%m-%d    result_format=epoch
        ${start_date}=        Convert Date    ${START_DATE}    date_format=%Y-%m-%d    result_format=epoch
        ${end_date}=          Convert Date    ${END_DATE}      date_format=%Y-%m-%d    result_format=epoch

        Should Be True      ${converted_date} >= ${start_date} 
        Should Be True      ${converted_date} <= ${end_date} 

*** Test Cases ***
Validate Random Dates Generator
    [Documentation]    This test verifies that 4 random dates are generated and fall within the specified interval.
    [tags]             random-date

    Open Browser        ${URL}     ${BROWSER}

    Wait Until Element Is Visible    xpath=//input[@name='num']    timeout=10s
    
    Input Text      xpath=//input[@name='num']               4

    Select From List By Label    name=start_month    January
    Select From List By Value    name=start_day      5
    Select From List By Value    name=start_year     2024
    Select From List By Label    name=end_month      November
    Select From List By Value    name=end_day        25
    Select From List By Value    name=end_year       2025

    Click Button    xpath=//input[@value='Get Dates']
    Wait Until Page Contains Element    css=p[style="line-height: 1.4em; margin-left: 2em"]    

    ${text_result}=    Get Text         css:h2 + p
    Should Contain     ${text_result}   Here are your 4 calendar dates

    ${dates_paragraph_text}=       Get Text                 css:p[style="line-height: 1.4em; margin-left: 2em"]
    ${dates_list}=                 String.Split To Lines    ${dates_paragraph_text}
    ${length}=                     Get Length               ${dates_list}
    Should Be Equal As Integers    ${length}    4

    FOR  ${date}  IN  @{dates_list}
        Date Should Be Between      ${date}     ${START_DATE}     ${END_DATE}
    END

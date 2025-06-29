*** Settings ***
Library           SeleniumLibrary
Library           DateTime
Library           String
Suite Teardown    Close Browser

*** Variables ***
${URL}           https://www.random.org/calendar-dates/   
${BROWSER}       chrome
${DATE_RANGE_START_LIMIT}    2024-01-05
${DATE_RANGE_END_LIMIT}      2025-11-25

# Selectors
${SELECTOR_NUM_INPUT}                xpath=//input[@name='num']
${SELECTOR_START_MONTH_DROPDOWN}     name=start_month
${SELECTOR_START_DAY_DROPDOWN}       name=start_day
${SELECTOR_START_YEAR_DROPDOWN}      name=start_year
${SELECTOR_END_MONTH_DROPDOWN}       name=end_month
${SELECTOR_END_DAY_DROPDOWN}         name=end_day
${SELECTOR_END_YEAR_DROPDOWN}        name=end_year
${SELECTOR_GET_DATES_BUTTON}         xpath=//input[@value='Get Dates']
${SELECTOR_DATES_PARAGRAPH}          css=p[style="line-height: 1.4em; margin-left: 2em"]
${SELECTOR_HEADER_TEXT_RESULT}       css:h2 + p

*** keywords ***
Date Should Be Between
    [Documentation]    Verifies if a given date falls within a specified start and end date.
    [Arguments]        ${date_to_check}    ${start_limit}    ${end_limit}

    ${converted_date}=      Convert Date    ${date_to_check}    date_format=%Y-%m-%d    result_format=epoch
    ${start_epoch}=         Convert Date    ${start_limit}      date_format=%Y-%m-%d    result_format=epoch
    ${end_epoch}=           Convert Date    ${end_limit}        date_format=%Y-%m-%d    result_format=epoch

    Should Be True          ${converted_date} >= ${start_epoch}    msg=Date ${date_to_check} (${converted_date}) is before start limit ${start_limit} (${start_epoch}).
    Should Be True          ${converted_date} <= ${end_epoch}      msg=Date ${date_to_check} (${converted_date}) is after end limit ${end_limit} (${end_epoch}).


Set Number Of Dates To Generate
    [Documentation]    Inputs the desired number of dates to be generated.
    [Arguments]        ${num_dates}
    
    Wait Until Element Is Visible    ${SELECTOR_NUM_INPUT}    timeout=10s
    Input Text                       ${SELECTOR_NUM_INPUT}    ${num_dates}

Select Date Range For Generator
    [Documentation]    Selects the start and end dates for the random date generator.  
    [Arguments]    ${start_month}   ${start_day}    ${start_year}   ${end_month}   ${end_day}    ${end_year}

    Select From List By Label    ${SELECTOR_START_MONTH_DROPDOWN}    ${start_month}
    Select From List By Value    ${SELECTOR_START_DAY_DROPDOWN}      ${start_day}
    Select From List By Value    ${SELECTOR_START_YEAR_DROPDOWN}     ${start_year}
    Select From List By Label    ${SELECTOR_END_MONTH_DROPDOWN}      ${end_month}
    Select From List By Value    ${SELECTOR_END_DAY_DROPDOWN}        ${end_day}
    Select From List By Value    ${SELECTOR_END_YEAR_DROPDOWN}       ${end_year}

*** Test Cases ***
Validate Random Dates Generator
    [Documentation]    This test verifies that the specified number of random dates are generated and fall within the chosen interval.
    [tags]             random-date

    Open Browser                     ${URL}                   ${BROWSER}
    Set Number Of Dates To Generate    4
    
    Select Date Range For Generator    January    5    2024    November    25    2025
    Click Button          ${SELECTOR_GET_DATES_BUTTON}

    # Validate the text results
    Wait Until Page Contains Element    ${SELECTOR_DATES_PARAGRAPH}    
    ${text_result}=    Get Text         ${SELECTOR_HEADER_TEXT_RESULT}
    Should Contain     ${text_result}   Here are your 4 calendar dates

    # Get, clean and Validate the generated dates
    ${dates_paragraph_text}=       Get Text                 ${SELECTOR_DATES_PARAGRAPH}
    ${dates_list}=                 String.Split To Lines    ${dates_paragraph_text}
    ${length}=                     Get Length               ${dates_list}
    Should Be Equal As Integers    ${length}    4

    FOR  ${date}  IN  @{dates_list}
        Date Should Be Between      ${date}     ${DATE_RANGE_START_LIMIT}     ${DATE_RANGE_END_LIMIT}
    END

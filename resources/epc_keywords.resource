*** Settings ***
Library           RequestsLibrary
Library           Collections

*** Variables ***
${BASE_URL}       http://epc-simulator:8000

*** Keywords ***

Setup Simulator Session
    Create Session    epc    ${BASE_URL}

Reset Simulator
    POST On Session    epc    /reset    expected_status=any

Attach Device With ID "${ue_id}" To Network
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${dane}=    Create Dictionary    ue_id=${ue_id_int}
    ${response}=    POST On Session    epc    /ues    json=${dane}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Detach Device With ID "${ue_id}" From Network
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${response}=    DELETE On Session    epc    /ues/${ue_id_int}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Get Status Of Device "${ue_id}"
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${response}=    GET On Session    epc    /ues/${ue_id_int}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Response Status Should Be
    [Arguments]    ${expected_code}
    Should Be Equal As Integers    ${LAST_RESPONSE.status_code}    ${expected_code}

Response Should Contain Key With Value
    [Arguments]    ${key}    ${value}
    Should Be Equal    ${LAST_RESPONSE.json()}[${key}]    ${value}

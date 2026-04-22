*** Settings ***
Library    RequestsLibrary
Library    Collections

Suite Setup    Create Session    epc    http://localhost:8000

*** Variables ***
${VALID_UE}        ${5}
${VALID_BEARER}    ${9}
${SPEED_MBPS}      ${10}

*** Test Cases ***

TC_01 Rozpoczęcie transferu z prawidłową prędkością zwraca 200 i poprawne dane
    [Tags]       traffic    start    happy-path    smoke
    [Setup]      Full Setup With Bearer    ${VALID_UE}    ${VALID_BEARER}
    [Teardown]   Full Teardown With Bearer    ${VALID_UE}    ${VALID_BEARER}
    ${resp}=     Start Traffic    ${VALID_UE}    ${VALID_BEARER}    ${SPEED_MBPS}
    Response Status Should Be                ${resp}    200
    Response Should Contain UE And Bearer    ${resp}    ${VALID_UE}    ${VALID_BEARER}
    Response Field Should Be Greater Than    ${resp}    target_bps    ${0}

*** Keywords ***

Full Setup With Bearer
    [Documentation]    Attach UE and add bearer so traffic endpoint is reachable
    [Arguments]    ${ue_id}    ${bearer_id}
    Attach UE       ${ue_id}
    Add Bearer      ${ue_id}    ${bearer_id}

Full Teardown With Bearer
    [Documentation]    Stop any running traffic, remove bearer, detach UE
    [Arguments]    ${ue_id}    ${bearer_id}
    Stop Traffic Silently    ${ue_id}    ${bearer_id}
    Remove Bearer            ${ue_id}    ${bearer_id}
    Detach UE                ${ue_id}

Attach UE
    [Arguments]    ${ue_id}
    ${body}=    Create Dictionary    ue_id=${ue_id}
    POST On Session    epc    /ues    json=${body}    expected_status=any

Detach UE
    [Arguments]    ${ue_id}
    DELETE On Session    epc    /ues/${ue_id}    expected_status=any

Add Bearer
    [Arguments]    ${ue_id}    ${bearer_id}
    ${body}=    Create Dictionary    bearer_id=${bearer_id}
    POST On Session    epc    /ues/${ue_id}/bearers    json=${body}    expected_status=any

Remove Bearer
    [Arguments]    ${ue_id}    ${bearer_id}
    DELETE On Session    epc    /ues/${ue_id}/bearers/${bearer_id}    expected_status=any

Start Traffic
    [Arguments]    ${ue_id}    ${bearer_id}    ${mbps}
    ${body}=    Create Dictionary    protocol=tcp    Mbps=${mbps}
    ${resp}=    POST On Session    epc    /ues/${ue_id}/bearers/${bearer_id}/traffic    json=${body}    expected_status=any
    RETURN    ${resp}

Stop Traffic
    [Arguments]    ${ue_id}    ${bearer_id}
    ${resp}=    DELETE On Session    epc    /ues/${ue_id}/bearers/${bearer_id}/traffic    expected_status=any
    RETURN    ${resp}

Stop Traffic Silently
    [Documentation]    Stop traffic without failing the teardown if traffic was never started
    [Arguments]    ${ue_id}    ${bearer_id}
    Run Keyword And Ignore Error    Stop Traffic    ${ue_id}    ${bearer_id}

Response Status Should Be
    [Arguments]    ${resp}    ${expected_status}
    Should Be Equal As Integers    ${resp.status_code}    ${expected_status}

Response Should Contain UE And Bearer
    [Arguments]    ${resp}    ${ue_id}    ${bearer_id}
    Should Be Equal As Integers    ${resp.json()}[ue_id]        ${ue_id}
    Should Be Equal As Integers    ${resp.json()}[bearer_id]    ${bearer_id}

Response Field Should Be Greater Than
    [Arguments]    ${resp}    ${field}    ${value}
    Should Be True    ${resp.json()}[${field}] > ${value}

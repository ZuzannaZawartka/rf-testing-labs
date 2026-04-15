*** Settings ***
Library           RequestsLibrary
Library           Collections

Suite Setup       Create Session    epc    http://localhost:8000
Suite Teardown    Delete All Sessions

*** Test Cases ***

TC_01 Add Bearer To Attached UE
    [Tags]    bearer
    [Teardown]    DELETE On Session    epc    /ues/5    expected_status=any

    Given UE Is Attached With ID    5
    When Bearer Is Added To UE      5    3
    Then Response Should Be Success

*** Keywords ***

UE Is Attached With ID
    [Arguments]    ${ue_id}
    DELETE On Session    epc    /ues/${ue_id}    expected_status=any
    ${body}=    Create Dictionary    ue_id=${ue_id}
    POST On Session    epc    /ues    json=${body}

Bearer Is Added To UE
    [Arguments]    ${ue_id}    ${bearer_id}
    ${bearer_body}=    Create Dictionary    bearer_id=${bearer_id}
    ${resp}=    POST On Session    epc    /ues/${ue_id}/bearers    json=${bearer_body}
    Set Test Variable    ${LAST_RESPONSE}    ${resp}

Response Should Be Success
    Should Be Equal As Integers    ${LAST_RESPONSE.status_code}    200

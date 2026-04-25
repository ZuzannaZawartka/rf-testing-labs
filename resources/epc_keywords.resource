*** Settings ***
Library           RequestsLibrary
Library           Collections

*** Variables ***
${BASE_URL}       http://epc-simulator:8000

*** Keywords ***
Initialize Simulator Session
    Create Session    epc    ${BASE_URL}

Reset Machine
    POST On Session    epc    /reset    expected_status=any

Attach UE ${ue_id}
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${dane}=    Create Dictionary    ue_id=${ue_id_int}
    ${response}=    POST On Session    epc    /ues    json=${dane}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Detach UE ${ue_id}
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${response}=    DELETE On Session    epc    /ues/${ue_id_int}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Retrieve Status Of UE ${ue_id}
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${response}=    GET On Session    epc    /ues/${ue_id_int}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Add Bearer ${bearer_id} To UE ${ue_id}
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${bearer_id_int}=    Convert To Integer    ${bearer_id}
    ${dane}=    Create Dictionary    bearer_id=${bearer_id_int}
    ${response}=    POST On Session    epc    /ues/${ue_id_int}/bearers    json=${dane}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Remove Bearer ${bearer_id} From UE ${ue_id}
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${bearer_id_int}=    Convert To Integer    ${bearer_id}
    ${response}=    DELETE On Session    epc    /ues/${ue_id_int}/bearers/${bearer_id_int}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Start Traffic On UE ${ue_id} With Bearer ${bearer_id} At ${mbps} Mbps
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${bearer_id_int}=    Convert To Integer    ${bearer_id}
    ${mbps_int}=    Convert To Integer    ${mbps}
    ${dane}=    Create Dictionary    protocol=udp    Mbps=${mbps_int}
    ${response}=    POST On Session    epc    /ues/${ue_id_int}/bearers/${bearer_id_int}/traffic    json=${dane}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Stop Traffic On UE ${ue_id} With Bearer ${bearer_id}
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${bearer_id_int}=    Convert To Integer    ${bearer_id}
    ${response}=    DELETE On Session    epc    /ues/${ue_id_int}/bearers/${bearer_id_int}/traffic    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Stop Traffic Silently On UE ${ue_id} With Bearer ${bearer_id}
    Run Keyword And Ignore Error    Stop Traffic On UE ${ue_id} With Bearer ${bearer_id}

Retrieve Traffic Stats For UE ${ue_id} On Bearer ${bearer_id}
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${bearer_id_int}=    Convert To Integer    ${bearer_id}
    ${response}=    GET On Session    epc    /ues/${ue_id_int}/bearers/${bearer_id_int}/traffic    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Response Should Be Successful
    Should Be Equal As Integers    ${LAST_RESPONSE.status_code}    200

Response Should Match Status ${expected_code}
    Should Be Equal As Integers    ${LAST_RESPONSE.status_code}    ${expected_code}

Verify UE ${ue_id} Is Attached Successfully
    Response Should Be Successful
    Should Be Equal    ${LAST_RESPONSE.json()}[status]    attached

Verify UE ${ue_id} Is Detached Successfully
    Response Should Be Successful
    Should Be Equal    ${LAST_RESPONSE.json()}[status]    detached

Verify Field ${field} Contains ${expected}
    Should Be Equal    ${LAST_RESPONSE.json()}[${field}]    ${expected}

Verify Field ${field} Is Greater Than ${value}
    Should Be True    ${LAST_RESPONSE.json()}[${field}] > ${value}

Verify Field ${field} Is Present
    Dictionary Should Contain Key    ${LAST_RESPONSE.json()}    ${field}

Verify Traffic Throughput Is Approximately ${expected_mbps} Mbps
    ${actual_bps}=    Set Variable    ${LAST_RESPONSE.json()}[target_bps]
    ${expected_bps}=    Evaluate    ${expected_mbps} * 1000000
    ${threshold}=    Evaluate    ${expected_bps} * 0.9
    Should Be True    ${actual_bps} >= ${threshold}    Expected at least ${threshold} bps (90% of ${expected_mbps} Mbps), but got ${actual_bps} bps

Verify Error Message Contains
    [Arguments]    ${expected_text}
    Should Not Be Equal As Integers    ${LAST_RESPONSE.status_code}    200
    ${response_json}=    Set Variable    ${LAST_RESPONSE.json()}
    ${detail}=    Get From Dictionary    ${response_json}    detail
    ${detail_str}=    Convert To String    ${detail}
    Should Contain    ${detail_str}    ${expected_text}    ignore_case=True

Verify Error Message For Duplicate UE Attachment
    Verify Error Message Contains    already attached

Verify Error Message For UE ID Out Of Range
    [Documentation]    Dokumentacja: zakres 0-100.
    Verify Message Contains Boundary    0    100

Verify Error Message For Non-Existent UE
    Verify Error Message Contains    not found

Verify Error Message For Maximum Traffic Limit Exceeded
    Verify Error Message Contains    exceeds maximum limit

Verify Error Message For Inactive Bearer
    Verify Error Message Contains    bearer not found

Verify Error Message For Deleting Default Bearer
    Verify Error Message Contains    cannot remove default bearer

Verify Error Message For Bearer ID Out Of Range
    [Documentation]    Dokumentacja: zakres 1-9.
    Verify Message Contains Boundary    1    9

Verify Message Contains Boundary
    [Arguments]    ${lower}    ${upper}
    ${detail}=    Convert To String    ${LAST_RESPONSE.json()}[detail]
    Run Keyword If    '${lower}' in """${detail}""" or '${upper}' in """${detail}"""    Return From Keyword
    Fail    Komunikat błędu nie odnosi się do granic zakresu ${lower}-${upper} określonego w dokumentacji (Otrzymano: ${detail})

UE "${ue_id}" is attached to the network
    Attach UE ${ue_id}
    Response Should Be Successful

bearer "${bearer_id}" is added to UE "${ue_id}"
    Add Bearer ${bearer_id} To UE ${ue_id}
    Response Should Be Successful

I start traffic for UE "${ue_id}" on bearer "${bearer_id}" at "${mbps}" Mbps
    Start Traffic On UE ${ue_id} With Bearer ${bearer_id} At ${mbps} Mbps
    Response Should Be Successful

the system should reject the request with an error
    Should Not Be Equal As Integers    ${LAST_RESPONSE.status_code}    200

the operation should be successful
    Response Should Be Successful
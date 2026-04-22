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
    # Połączono funkcjonalności ACK dla Attach i Detach, ponieważ bez tego system traci stabilność
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${dane}=    Create Dictionary    ue_id=${ue_id_int}
    ${response}=    POST On Session    epc    /ues    json=${dane}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Detach UE ${ue_id}
    # Połączono funkcjonalności ACK dla Attach i Detach, ponieważ bez tego system traci stabilność
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${response}=    DELETE On Session    epc    /ues/${ue_id_int}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Get Status Of UE ${ue_id}
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
    ${dane}=    Create Dictionary    protocol=tcp    Mbps=${mbps_int}
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

# Verification Keywords

Response Should Be Successful
    Should Be Equal As Integers    ${LAST_RESPONSE.status_code}    200

Response Should Match Status ${expected_code}
    Should Be Equal As Integers    ${LAST_RESPONSE.status_code}    ${expected_code}

Verify UE ${ue_id} Attached Successfully
    Response Should Be Successful
    Should Be Equal    ${LAST_RESPONSE.json()}[status]    attached

Verify UE ${ue_id} Detached Successfully
    Response Should Be Successful
    Should Be Equal    ${LAST_RESPONSE.json()}[status]    detached

Verify Field ${field} Contains ${expected}
    Should Be Equal    ${LAST_RESPONSE.json()}[${field}]    ${expected}

Verify Field ${field} Is Greater Than ${value}
    Should Be True    ${LAST_RESPONSE.json()}[${field}] > ${value}

Verify Field ${field} Is Present
    Dictionary Should Contain Key    ${LAST_RESPONSE.json()}    ${field}


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

Add Bearer With ID "${bearer_id}" To UE "${ue_id}"
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${bearer_id_int}=    Convert To Integer    ${bearer_id}
    ${dane}=    Create Dictionary    bearer_id=${bearer_id_int}
    ${response}=    POST On Session    epc    /ues/${ue_id_int}/bearers    json=${dane}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Remove Bearer With ID "${bearer_id}" From UE "${ue_id}"
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${bearer_id_int}=    Convert To Integer    ${bearer_id}
    ${response}=    DELETE On Session    epc    /ues/${ue_id_int}/bearers/${bearer_id_int}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Start Traffic On Bearer "${bearer_id}" Of UE "${ue_id}" With Speed "${mbps}"
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${bearer_id_int}=    Convert To Integer    ${bearer_id}
    ${mbps_int}=    Convert To Integer    ${mbps}
    ${dane}=    Create Dictionary    protocol=tcp    Mbps=${mbps_int}
    ${response}=    POST On Session    epc    /ues/${ue_id_int}/bearers/${bearer_id_int}/traffic    json=${dane}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Stop Traffic On Bearer "${bearer_id}" Of UE "${ue_id}"
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${bearer_id_int}=    Convert To Integer    ${bearer_id}
    ${response}=    DELETE On Session    epc    /ues/${ue_id_int}/bearers/${bearer_id_int}/traffic    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Stop Traffic Silently On Bearer "${bearer_id}" Of UE "${ue_id}"
    Run Keyword And Ignore Error    Stop Traffic On Bearer "${bearer_id}" Of UE "${ue_id}"

Get Traffic Stats On Bearer "${bearer_id}" Of UE "${ue_id}"
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${bearer_id_int}=    Convert To Integer    ${bearer_id}
    ${response}=    GET On Session    epc    /ues/${ue_id_int}/bearers/${bearer_id_int}/traffic    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Response Status Should Be
    [Arguments]    ${expected_code}
    Should Be Equal As Integers    ${LAST_RESPONSE.status_code}    ${expected_code}

Response Should Contain Key With Value
    [Arguments]    ${key}    ${value}
    Should Be Equal    ${LAST_RESPONSE.json()}[${key}]    ${value}

Response Should Contain UE "${ue_id}" And Bearer "${bearer_id}"
    Should Be Equal As Integers    ${LAST_RESPONSE.json()}[ue_id]        ${ue_id}
    Should Be Equal As Integers    ${LAST_RESPONSE.json()}[bearer_id]    ${bearer_id}

Response Field "${field}" Should Be Greater Than ${value}
    Should Be True    ${LAST_RESPONSE.json()}[${field}] > ${value}

Response Field "${field}" Should Be Greater Or Equal ${value}
    Should Be True    ${LAST_RESPONSE.json()}[${field}] >= ${value}

Response Field "${field}" Should Equal
    [Arguments]    ${expected}
    Should Be Equal    ${LAST_RESPONSE.json()}[${field}]    ${expected}

Response Field "${field}" Should Be Present
    Dictionary Should Contain Key    ${LAST_RESPONSE.json()}    ${field}

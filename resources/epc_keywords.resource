*** Settings ***
Library           RequestsLibrary
Library           Collections

*** Variables ***
${BASE_URL}       http://epc-simulator:8000

*** Keywords ***

Initialize Simulator Session
    Create Session    epc    ${BASE_URL}

Reset Simulator
    POST On Session    epc    /reset    expected_status=any

Attach UE ${ue_id}
    ${ue_id_int}=      Convert To Integer    ${ue_id}
    ${body}=           Create Dictionary    ue_id=${ue_id_int}
    ${response}=       POST On Session    epc    /ues    json=${body}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Detach UE ${ue_id}
    ${ue_id_int}=      Convert To Integer    ${ue_id}
    ${response}=       DELETE On Session    epc    /ues/${ue_id_int}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Retrieve UE ${ue_id} Status
    ${ue_id_int}=      Convert To Integer    ${ue_id}
    ${response}=       GET On Session    epc    /ues/${ue_id_int}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Add Bearer ${bearer_id} To UE ${ue_id}
    ${ue_id_int}=      Convert To Integer    ${ue_id}
    ${bearer_id_int}=  Convert To Integer    ${bearer_id}
    ${body}=           Create Dictionary    bearer_id=${bearer_id_int}
    ${response}=       POST On Session    epc    /ues/${ue_id_int}/bearers    json=${body}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Remove Bearer ${bearer_id} From UE ${ue_id}
    ${ue_id_int}=      Convert To Integer    ${ue_id}
    ${bearer_id_int}=  Convert To Integer    ${bearer_id}
    ${response}=       DELETE On Session    epc    /ues/${ue_id_int}/bearers/${bearer_id_int}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Start Traffic On UE ${ue_id} Bearer ${bearer_id} At ${mbps} Mbps
    ${ue_id_int}=      Convert To Integer    ${ue_id}
    ${bearer_id_int}=  Convert To Integer    ${bearer_id}
    ${mbps_int}=       Convert To Integer    ${mbps}
    # protocol is required by the API schema (must be 'tcp' or 'udp')
    ${body}=           Create Dictionary    protocol=udp    Mbps=${mbps_int}
    ${response}=       POST On Session    epc    /ues/${ue_id_int}/bearers/${bearer_id_int}/traffic    json=${body}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Start Traffic On UE ${ue_id} Bearer ${bearer_id} At ${value} kbps
    ${ue_id_int}=      Convert To Integer    ${ue_id}
    ${bearer_id_int}=  Convert To Integer    ${bearer_id}
    ${kbps_int}=       Convert To Integer    ${value}
    # protocol is required by the API schema (must be 'tcp' or 'udp')
    ${body}=           Create Dictionary    protocol=udp    kbps=${kbps_int}
    ${response}=       POST On Session    epc    /ues/${ue_id_int}/bearers/${bearer_id_int}/traffic    json=${body}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Start Traffic On UE ${ue_id} Bearer ${bearer_id} Protocol ${protocol} At ${mbps} Mbps
    ${ue_id_int}=      Convert To Integer    ${ue_id}
    ${bearer_id_int}=  Convert To Integer    ${bearer_id}
    ${mbps_int}=       Convert To Integer    ${mbps}
    ${body}=           Create Dictionary    protocol=${protocol}    Mbps=${mbps_int}
    ${response}=       POST On Session    epc    /ues/${ue_id_int}/bearers/${bearer_id_int}/traffic    json=${body}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Stop Traffic On UE ${ue_id} Bearer ${bearer_id}
    ${ue_id_int}=      Convert To Integer    ${ue_id}
    ${bearer_id_int}=  Convert To Integer    ${bearer_id}
    ${response}=       DELETE On Session    epc    /ues/${ue_id_int}/bearers/${bearer_id_int}/traffic    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Stop All Traffic For UE ${ue_id}
    ${ue_id_int}=      Convert To Integer    ${ue_id}
    ${response}=       DELETE On Session    epc    /ues/${ue_id_int}/traffic    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Retrieve Traffic Stats For UE ${ue_id} Bearer ${bearer_id}
    ${ue_id_int}=      Convert To Integer    ${ue_id}
    ${bearer_id_int}=  Convert To Integer    ${bearer_id}
    ${response}=       GET On Session    epc    /ues/${ue_id_int}/bearers/${bearer_id_int}/traffic    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}



Retrieve Aggregate Traffic Stats For UE ${ue_id}
    ${ue_id_int}=      Convert To Integer    ${ue_id}
    ${response}=       GET On Session    epc    /ues/${ue_id_int}/traffic    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Verify UE ${ue_id} Attached Successfully
    Should Be Equal As Integers    ${LAST_RESPONSE.status_code}    200
    Should Be Equal               ${LAST_RESPONSE.json()}[status]    attached

Verify UE ${ue_id} Detached Successfully
    Should Be Equal As Integers    ${LAST_RESPONSE.status_code}    200
    Should Be Equal               ${LAST_RESPONSE.json()}[status]    detached

Verify Bearer ${bearer_id} Added To UE ${ue_id} Successfully
    Should Be Equal As Integers    ${LAST_RESPONSE.status_code}    200

Verify Bearer ${bearer_id} Removed From UE ${ue_id} Successfully
    Should Be Equal As Integers    ${LAST_RESPONSE.status_code}    200

Verify UE ${ue_id} Status Retrieved Successfully
    Should Be Equal As Integers    ${LAST_RESPONSE.status_code}    200

Verify Default Bearer ${bearer_id} Exists For UE ${ue_id}
    Retrieve Traffic Stats For UE ${ue_id} Bearer ${bearer_id}
    Should Be Equal As Integers    ${LAST_RESPONSE.status_code}    200

Verify Traffic Started At Around ${expected_mbps} Mbps
    Should Be Equal As Integers    ${LAST_RESPONSE.status_code}    200
    ${actual_bps}=     Set Variable    ${LAST_RESPONSE.json()}[target_bps]
    ${expected_bps}=   Evaluate    ${expected_mbps} * 1000000
    ${lower_bps}=      Evaluate    ${expected_bps} * 0.9
    ${upper_bps}=      Evaluate    ${expected_bps} * 1.1
    Should Be True    ${actual_bps} >= ${lower_bps}
    ...    Expected >= ${lower_bps} bps (90%% of ${expected_mbps} Mbps), got ${actual_bps}
    Should Be True    ${actual_bps} <= ${upper_bps}
    ...    Expected <= ${upper_bps} bps (110%% of ${expected_mbps} Mbps), got ${actual_bps}

Verify Traffic Stopped On UE ${ue_id} Bearer ${bearer_id} Successfully
    Should Be Equal As Integers    ${LAST_RESPONSE.status_code}    200

Verify All Traffic Stopped For UE ${ue_id} Successfully
    Should Be Equal As Integers    ${LAST_RESPONSE.status_code}    200

Verify Traffic Uses Protocol
    [Arguments]    ${expected_protocol}
    ${json}=    Set Variable    ${LAST_RESPONSE.json()}
    ${has_protocol}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${json}    protocol
    Run Keyword If    not ${has_protocol}    Fail    Defect: Response JSON is missing the 'protocol' key.
    Should Be Equal    ${json}[protocol]    ${expected_protocol}

Verify Field ${field} Is Present In Response
    Dictionary Should Contain Key    ${LAST_RESPONSE.json()}    ${field}

Verify Traffic Stats Returned In kbps
    ${response_json}=    Set Variable    ${LAST_RESPONSE.json()}
    Should Be Equal As Integers    ${LAST_RESPONSE.status_code}    200
    ${has_unit}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${response_json}    unit
    Run Keyword If    ${has_unit}    Should Be Equal    ${response_json}[unit]    kbps

Verify Response Contains Error Matching
    [Arguments]    ${expected_text}
    Should Not Be Equal As Integers    ${LAST_RESPONSE.status_code}    200
    ${detail}=      Get From Dictionary    ${LAST_RESPONSE.json()}    detail
    ${detail_str}=  Convert To String    ${detail}
    Should Contain    ${detail_str}    ${expected_text}    ignore_case=True

Verify Response Contains Range Error For Boundary
    [Arguments]    ${lower}    ${upper}
    Should Not Be Equal As Integers    ${LAST_RESPONSE.status_code}    200
    ${detail}=      Convert To String    ${LAST_RESPONSE.json()}[detail]
    ${has_lower}=   Run Keyword And Return Status    Should Contain    ${detail}    ${lower}
    ${has_upper}=   Run Keyword And Return Status    Should Contain    ${detail}    ${upper}
    Run Keyword If    not ${has_lower} and not ${has_upper}
    ...    Fail    Error message should reference range ${lower}-${upper}. Got: ${detail}

Verify UE Attachment Rejected As Duplicate
    Verify Response Contains Error Matching    already attached

Verify UE ID Rejected As Out Of Range
    Verify Response Contains Range Error For Boundary    0    100

Verify UE Detachment Rejected As Not Found
    Verify Response Contains Error Matching    not found

Verify Traffic Rejected As Exceeding Maximum Limit
    Verify Response Contains Error Matching    exceeds maximum limit

Verify Traffic Rejected Due To Inactive Bearer
    Verify Response Contains Error Matching    bearer not found

Verify Default Bearer Deletion Rejected
    Verify Response Contains Error Matching    cannot remove default bearer

Verify Bearer ID Rejected As Out Of Range
    Verify Response Contains Range Error For Boundary    1    9

Verify Bearer Addition Rejected As Duplicate
    Verify Response Contains Error Matching    already exists

Verify Bearer Rejected As Not Found
    Verify Response Contains Error Matching    Bearer not found

Verify Throughput Value Rejected As Invalid
    Should Not Be Equal As Integers    ${LAST_RESPONSE.status_code}    200

Prepare Attached UE ${ue_id} With Bearer ${bearer_id}
    # Attach and bearer addition are combined, bearer operations require an attached UE
    Attach UE ${ue_id}
    Add Bearer ${bearer_id} To UE ${ue_id}

Prepare Attached UE ${ue_id} With Active Traffic On Bearer ${bearer_id} At ${mbps} Mbps
    # Attach, bearer addition and traffic start are combined, all three steps are required
    # before any traffic-state verification can be performed.
    Prepare Attached UE ${ue_id} With Bearer ${bearer_id}
    Start Traffic On UE ${ue_id} Bearer ${bearer_id} At ${mbps} Mbps

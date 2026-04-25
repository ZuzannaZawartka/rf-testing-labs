*** Settings ***
Resource          ../resources/epc_keywords.resource
Documentation     Traffic defect discovery tests - discrepancies between documentation and implementation.
Suite Setup       Initialize Simulator Session
Suite Teardown    Reset Machine
Test Teardown     Reset Machine

*** Test Cases ***

# --- DEF-001 extension: max 100 Mbps limit not enforced for kbps and bps units ---

TC-030 Reject Traffic Exceeding 100 Mbps Via kbps Parameter
    [Documentation]    Requirement: "zakres transferu – max 100 Mbps dla UE". 101 000 kbps = 101 Mbps should be rejected.
    [Tags]             compliance    negative    bug-discovery
    Attach UE 5
    Start Traffic On UE 5 With Bearer 9 At 101000 kbps
    Verify Error Message For Maximum Traffic Limit Exceeded

# --- DEF: Aggregate 100 Mbps limit not enforced across bearers ---

TC-031 Reject Traffic When Aggregate Exceeds 100 Mbps Across Two Bearers
    [Documentation]    Requirement: "zakres transferu – max 100 Mbps dla UE". 60+60=120 Mbps should be rejected.
    [Tags]             compliance    negative    bug-discovery
    Attach UE 5
    Add Bearer 1 To UE 5
    Start Traffic On UE 5 With Bearer 9 At 60 Mbps
    Response Should Be Successful
    Start Traffic On UE 5 With Bearer 1 At 60 Mbps
    Verify Error Message For Maximum Traffic Limit Exceeded

# --- DEF: GET traffic stats missing unit parameter (default kbps per documentation) ---

TC-032 Traffic Stats Should Default To kbps Unit
    [Documentation]    Requirement: "Domyślną jednostką jest kbps". Response values should be in kbps, not bps.
    [Tags]             traffic    stats    compliance    bug-discovery
    [Setup]    Prepare UE 5 With Active Traffic 9 At 10 Mbps
    Sleep    2s
    Retrieve Traffic Stats For UE 5 On Bearer 9
    Response Should Be Successful
    Verify Traffic Stats Are In kbps

# --- DEF: Stop all traffic for UE endpoint missing ---

TC-033 Stop All Traffic For UE At Once
    [Documentation]    Requirement: "Transfer danych można zakończyć... całkowicie dla wszystkich bearerów". DELETE /ues/{ue_id}/traffic endpoint should exist.
    [Tags]             traffic    compliance    bug-discovery
    Attach UE 5
    Add Bearer 1 To UE 5
    Start Traffic On UE 5 With Bearer 9 At 10 Mbps
    Start Traffic On UE 5 With Bearer 1 At 5 Mbps
    Stop All Traffic For UE 5
    Response Should Be Successful

*** Keywords ***

Start Traffic On UE ${ue_id} With Bearer ${bearer_id} At ${value} kbps
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${bearer_id_int}=    Convert To Integer    ${bearer_id}
    ${kbps_int}=    Convert To Integer    ${value}
    ${dane}=    Create Dictionary    protocol=udp    kbps=${kbps_int}
    ${response}=    POST On Session    epc    /ues/${ue_id_int}/bearers/${bearer_id_int}/traffic    json=${dane}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Start Traffic On UE ${ue_id} With Bearer ${bearer_id} At ${value} bps
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${bearer_id_int}=    Convert To Integer    ${bearer_id}
    ${bps_int}=    Convert To Integer    ${value}
    ${dane}=    Create Dictionary    protocol=udp    bps=${bps_int}
    ${response}=    POST On Session    epc    /ues/${ue_id_int}/bearers/${bearer_id_int}/traffic    json=${dane}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Start Traffic On UE ${ue_id} With Bearer ${bearer_id} Using TCP At ${mbps} Mbps
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${bearer_id_int}=    Convert To Integer    ${bearer_id}
    ${mbps_int}=    Convert To Integer    ${mbps}
    ${dane}=    Create Dictionary    protocol=tcp    Mbps=${mbps_int}
    ${response}=    POST On Session    epc    /ues/${ue_id_int}/bearers/${bearer_id_int}/traffic    json=${dane}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Start Traffic On UE ${ue_id} With Bearer ${bearer_id} Using Protocol ${protocol} At ${mbps} Mbps
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${bearer_id_int}=    Convert To Integer    ${bearer_id}
    ${mbps_int}=    Convert To Integer    ${mbps}
    ${dane}=    Create Dictionary    protocol=${protocol}    Mbps=${mbps_int}
    ${response}=    POST On Session    epc    /ues/${ue_id_int}/bearers/${bearer_id_int}/traffic    json=${dane}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Start Traffic On UE ${ue_id} With Bearer ${bearer_id} With No Throughput
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${bearer_id_int}=    Convert To Integer    ${bearer_id}
    ${dane}=    Create Dictionary    protocol=udp
    ${response}=    POST On Session    epc    /ues/${ue_id_int}/bearers/${bearer_id_int}/traffic    json=${dane}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Start Traffic On UE ${ue_id} With Bearer ${bearer_id} With Both Mbps And kbps
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${bearer_id_int}=    Convert To Integer    ${bearer_id}
    ${dane}=    Create Dictionary    protocol=udp    Mbps=${10}    kbps=${10000}
    ${response}=    POST On Session    epc    /ues/${ue_id_int}/bearers/${bearer_id_int}/traffic    json=${dane}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Stop All Traffic For UE ${ue_id}
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${response}=    DELETE On Session    epc    /ues/${ue_id_int}/traffic    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Retrieve Traffic Stats For UE ${ue_id} On Bearer ${bearer_id} With Unit ${unit}
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${bearer_id_int}=    Convert To Integer    ${bearer_id}
    ${response}=    GET On Session    epc    /ues/${ue_id_int}/bearers/${bearer_id_int}/traffic    params=unit=${unit}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

Verify Traffic Stats Are In kbps
    [Documentation]    10 Mbps = 10 000 kbps. If response is in bps the value would be ~10 000 000.
    ${target}=    Set Variable    ${LAST_RESPONSE.json()}[target_bps]
    Should Be True    ${target} <= 100000
    ...    Expected value in kbps (<=100000 for max 100 Mbps), but got ${target} - response appears to be in bps

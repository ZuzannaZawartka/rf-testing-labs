*** Settings ***
Resource          ../resources/epc_keywords.resource
Documentation     Advanced logic tests and documentation discrepancy discovery.
Suite Setup       Initialize Simulator Session
Suite Teardown    Reset Machine
Test Teardown     Reset Machine

*** Test Cases ***

TC-023 Reject Negative Traffic Throughput
    [Documentation]    Check if system prevents negative throughput values.
    [Tags]             traffic    negative    bug-discovery
    Given UE "10" is attached to the network
    When I try to start traffic for UE "10" on bearer "9" at "-10" Mbps
    Then the system should reject the request with an error

TC-024 Enforce Aggregate Throughput Limit For Multiple Bearers
    [Documentation]    Requirement: "zakres transferu – max 100 Mbps dla UE". Check if sum of two bearers (60+60) is blocked.
    [Tags]             traffic    compliance    bug-discovery
    Given UE "20" is attached to the network
    And bearer "1" is added to UE "20"
    When I start traffic for UE "20" on bearer "9" at "60" Mbps
    And I try to start traffic for UE "20" on bearer "1" at "60" Mbps
    Then the system should reject the request with an error

TC-025 Reject Bearer ID Zero As Out Of Range
    [Documentation]    Requirement: "zakres bearerów dla UE: 1-9". Verify that ID 0 is rejected.
    [Tags]             bearer    boundary    bug-discovery
    Given UE "30" is attached to the network
    When I try to add bearer "0" to UE "30"
    Then the system should report a validation error "greater than or equal to 1"

TC-026 Validate Traffic Stats Unit Conversion
    [Documentation]    Requirement: "Domyślną jednostką jest kbps". Verify if unit parameter actually converts bps to kbps.
    [Tags]             traffic    stats    bug-discovery
    Given UE "50" is attached and has active traffic on bearer "9" at "1" Mbps
    When I request traffic stats for UE "50" with unit "kbps"
    Then the value should be converted from "bps" to "kbps"

TC-027 Support Stopping All Traffic For UE
    [Documentation]    Requirement: "Transfer danych można zakończyć... całkowicie dla wszystkich bearerów".
    [Tags]             traffic    cleanup    bug-discovery
    Given UE "60" is attached and has active traffic on bearer "9" at "10" Mbps
    When I try to stop all traffic for UE "60"
    Then the operation should be successful
    And traffic for UE "60" on bearer "9" should be inactive

TC-028 Validate Bearer Deletion Range Priority
    [Documentation]    Verify that deleting bearer 10 (out of range) returns range error (422) instead of not found (404).
    [Tags]             bearer    negative    bug-discovery
    Given UE "70" is attached to the network
    When I try to remove bearer "10" from UE "70"
    Then the system should report a range error zamiast not found

TC-029 Support UE ID Boundary Zero
    [Documentation]    Requirement: "zakres dostępnych UE: 0-100". Verify that UE ID 0 is accepted.
    [Tags]             attach    boundary    bug-discovery
    When I try to attach UE with ID "0"
    Then the operation should be successful

*** Keywords ***

Given UE "${ue_id}" is attached and has active traffic on bearer "${bearer_id}" at "${mbps}" Mbps
    Attach UE ${ue_id}
    Response Should Be Successful
    Start Traffic On UE ${ue_id} With Bearer ${bearer_id} At ${mbps} Mbps
    Response Should Be Successful

the value should be converted from "bps" to "kbps"
    ${json}=    Set Variable    ${LAST_RESPONSE.json()}
    ${status}=    Run Keyword And Return Status    Dictionary Should Contain Key    ${json}    target_bps
    Run Keyword If    not ${status}    Fail    Defect: Response JSON does not contain 'target_bps' field for unit conversion.
    ${target_bps}=    Get From Dictionary    ${json}    target_bps
    Should Be True    ${target_bps} < 100000    Expected kbps value (around 1000), but got high bps value: ${target_bps}

the system should report a range error zamiast not found
    ${status_code}=    Convert To Integer    ${LAST_RESPONSE.status_code}
    Should Be Equal As Integers    ${status_code}    422    Expected validation error (422) but got ${status_code}

I request traffic stats for UE "${ue_id}" with unit "${unit}"
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${response}=    GET On Session    epc    /ues/${ue_id_int}/traffic    params=unit=${unit}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

the system should report a validation error "${expected_technical_msg}"
    ${detail}=    Convert To String    ${LAST_RESPONSE.json()}
    Should Contain    ${detail}    ${expected_technical_msg}    ignore_case=True
    Should Not Be Equal As Integers    ${LAST_RESPONSE.status_code}    200

When I try to add bearer "${bearer_id}" to UE "${ue_id}"
    Add Bearer ${bearer_id} To UE ${ue_id}

When I try to stop all traffic for UE "${ue_id}"
    ${ue_id_int}=    Convert To Integer    ${ue_id}
    ${response}=    DELETE On Session    epc    /ues/${ue_id_int}/traffic    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${response}

And traffic for UE "${ue_id}" on bearer "${bearer_id}" should be inactive
    Retrieve Traffic Stats For UE ${ue_id} On Bearer ${bearer_id}
    Should Not Be Equal As Integers    ${LAST_RESPONSE.status_code}    200

When I try to remove bearer "${bearer_id}" from UE "${ue_id}"
    Remove Bearer ${bearer_id} From UE ${ue_id}

When I try to attach UE with ID "${ue_id}"
    Attach UE ${ue_id}

I try to start traffic for UE "${ue_id}" on bearer "${bearer_id}" at "${mbps}" Mbps
    Start Traffic On UE ${ue_id} With Bearer ${bearer_id} At ${mbps} Mbps
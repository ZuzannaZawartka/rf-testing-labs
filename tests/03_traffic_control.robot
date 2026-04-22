*** Settings ***
Resource          ../resources/epc_keywords.resource
Documentation     Traffic control tests.
Suite Setup       Initialize Simulator Session

*** Variables ***
${VALID_UE}        5
${VALID_BEARER}    9
${SPEED_MBPS}      10

*** Test Cases ***

TC-010: Start Traffic Successfully
    [Tags]       traffic    start    happy-path    smoke
    [Setup]      Prepare UE With Bearer    ${VALID_UE}    ${VALID_BEARER}
    [Teardown]   Cleanup UE With Bearer    ${VALID_UE}    ${VALID_BEARER}
    Start Traffic On UE ${VALID_UE} With Bearer ${VALID_BEARER} At ${SPEED_MBPS} Mbps
    Response Should Be Successful
    Verify Field target_bps Is Greater Than 0

TC-011: Stop Active Traffic Successfully
    [Tags]       traffic    stop    happy-path    smoke
    [Setup]      Prepare UE With Active Traffic    ${VALID_UE}    ${VALID_BEARER}    ${SPEED_MBPS}
    [Teardown]   Cleanup UE With Bearer    ${VALID_UE}    ${VALID_BEARER}
    Stop Traffic On UE ${VALID_UE} With Bearer ${VALID_BEARER}
    Response Should Be Successful

TC-012: Retrieve Traffic Stats Successfully
    [Tags]       traffic    stats    happy-path    smoke
    [Setup]      Prepare UE With Active Traffic    ${VALID_UE}    ${VALID_BEARER}    ${SPEED_MBPS}
    [Teardown]   Cleanup UE With Bearer    ${VALID_UE}    ${VALID_BEARER}
    Retrieve Traffic Stats For UE ${VALID_UE} On Bearer ${VALID_BEARER}
    Response Should Be Successful
    Verify Field protocol Contains tcp
    Verify Field target_bps Is Greater Than 0
    Verify Field tx_bps Is Present
    Verify Field rx_bps Is Present

*** Keywords ***

Prepare UE With Bearer
    [Arguments]    ${ue_id}    ${bearer_id}
    Reset Machine
    Attach UE ${ue_id}
    Add Bearer ${bearer_id} To UE ${ue_id}

Prepare UE With Active Traffic
    [Arguments]    ${ue_id}    ${bearer_id}    ${mbps}
    Prepare UE With Bearer    ${ue_id}    ${bearer_id}
    Start Traffic On UE ${ue_id} With Bearer ${bearer_id} At ${mbps} Mbps

Cleanup UE With Bearer
    [Arguments]    ${ue_id}    ${bearer_id}
    Stop Traffic Silently On UE ${ue_id} With Bearer ${bearer_id}
    Remove Bearer ${bearer_id} From UE ${ue_id}
    Detach UE ${ue_id}
    Reset Machine

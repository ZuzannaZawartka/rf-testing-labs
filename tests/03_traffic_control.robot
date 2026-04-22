*** Settings ***
Resource          ../resources/epc_keywords.resource
Documentation     Traffic control tests.
Suite Setup       Initialize Simulator Session
Suite Teardown    Reset Machine
Test Teardown     Reset Machine

*** Variables ***
${UE_ID}          5
${BEARER_ID}      9
${SPEED_MBPS}     10

*** Test Cases ***

TC-015: Start Traffic Successfully
    [Tags]       traffic    start    happy-path
    [Setup]      Prepare UE ${UE_ID} With Bearer ${BEARER_ID}
    Start Traffic On UE ${UE_ID} With Bearer ${BEARER_ID} At ${SPEED_MBPS} Mbps
    Response Should Be Successful
    Verify Field target_bps Is Greater Than 0


TC-016: Stop Active Traffic Successfully
    [Tags]       traffic    stop    happy-path
    [Setup]      Prepare UE ${UE_ID} With Active Traffic ${BEARER_ID} At ${SPEED_MBPS} Mbps
    Stop Traffic On UE ${UE_ID} With Bearer ${BEARER_ID}
    Response Should Be Successful


TC-017: Retrieve Traffic Stats Successfully
    [Tags]       traffic    stats    happy-path
    [Setup]      Prepare UE ${UE_ID} With Active Traffic ${BEARER_ID} At ${SPEED_MBPS} Mbps
    Retrieve Traffic Stats For UE ${UE_ID} On Bearer ${BEARER_ID}
    Response Should Be Successful
    Verify Field protocol Contains tcp
    Verify Field target_bps Is Greater Than 0
    Verify Field tx_bps Is Present
    Verify Field rx_bps Is Present


# TC demonstrating defect DEF-001
TC-018: Enforce Maximum Transfer Limit
    [Documentation]    Requirement: "zakres transferu, max 100 Mbps".
    [Tags]             compliance    negative    bug-discovery
    Prepare UE ${UE_ID} With Bearer ${BEARER_ID}
    # 101 Mbps is above the documented limit of 100 Mbps
    Start Traffic On UE ${UE_ID} With Bearer ${BEARER_ID} At 101 Mbps
    Response Should Match Status 400


TC-019: Prevent Traffic On Inactive Bearer
    [Documentation]    Requirement: "Jeśli bearer nie jest aktywny – zostanie wyświetlony błąd".
    [Tags]             compliance    negative
    Reset Machine
    Attach UE ${UE_ID}
    # Bearer 5 is never created
    Start Traffic On UE ${UE_ID} With Bearer 5 At ${SPEED_MBPS} Mbps
    Response Should Match Status 400



*** Keywords ***

Prepare UE ${ue_id} With Bearer ${bearer_id}
    Reset Machine
    Attach UE ${ue_id}
    Add Bearer ${bearer_id} To UE ${ue_id}

Prepare UE ${ue_id} With Active Traffic ${bearer_id} At ${mbps} Mbps
    Prepare UE ${ue_id} With Bearer ${bearer_id}
    Start Traffic On UE ${ue_id} With Bearer ${bearer_id} At ${mbps} Mbps



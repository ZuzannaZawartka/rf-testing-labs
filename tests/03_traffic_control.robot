*** Settings ***
Resource          ../resources/epc_keywords.resource
Documentation     Traffic control tests.
Suite Setup       Initialize Simulator Session
Suite Teardown    Reset Machine
Test Teardown     Reset Machine

*** Test Cases ***

TC-018 Start Traffic 10 Mbps Successfully For UE 5 On Bearer 9
    [Tags]       traffic    start    happy-path
    [Setup]      Prepare UE 5 With Bearer 9
    Start Traffic On UE 5 With Bearer 9 At 10 Mbps
    Response Should Be Successful
    Verify Traffic Throughput Is Approximately 10 Mbps


TC-019 Stop Active Traffic Successfully For UE 5 On Bearer 9
    [Tags]       traffic    stop    happy-path
    [Setup]      Prepare UE 5 With Active Traffic 9 At 10 Mbps
    Stop Traffic On UE 5 With Bearer 9
    Response Should Be Successful


TC-020 Retrieve Traffic Stats Successfully For UE 5 On Bearer 9
    [Tags]       traffic    stats    happy-path
    [Setup]      Prepare UE 5 With Active Traffic 9 At 10 Mbps
    Retrieve Traffic Stats For UE 5 On Bearer 9
    Response Should Be Successful
    Verify Field protocol Contains udp
    Verify Traffic Throughput Is Approximately 10 Mbps
    Verify Field tx_bps Is Present
    Verify Field rx_bps Is Present


# TC demonstrating defect DEF-001
TC-021 Enforce Maximum Transfer Limit Of 100 Mbps For UE 5 On Bearer 9
    [Documentation]    Requirement: "zakres transferu, max 100 Mbps".
    [Tags]             compliance    negative    bug-discovery
    Prepare UE 5 With Bearer 9
    # 101 Mbps is above the documented limit of 100 Mbps
    Start Traffic On UE 5 With Bearer 9 At 101 Mbps
    Verify Error Message For Maximum Traffic Limit Exceeded


TC-022 Prevent Traffic On Inactive Bearer 5 For UE 5
    [Documentation]    Requirement: "Jeśli bearer nie jest aktywny – zostanie wyświetlony błąd".
    [Tags]             compliance    negative
    Reset Machine
    Attach UE 5
    # Bearer 5 is never created
    Start Traffic On UE 5 With Bearer 5 At 10 Mbps
    Verify Error Message For Inactive Bearer



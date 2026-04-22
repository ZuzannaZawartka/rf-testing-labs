*** Settings ***
Resource          ../resources/epc_keywords.resource
Documentation     UE Attachment and Detachment tests based on documentation.
Suite Setup       Initialize Simulator Session
Suite Teardown    Reset Machine
Test Teardown     Reset Machine

*** Test Cases ***

TC-001 Attach UE 1 Successfully
    [Documentation]    Requirement: Verify successful UE attachment.
    [Tags]             positive    attach
    Attach UE 1
    Verify UE 1 Is Attached Successfully

TC-002 Reject UE ID 101 Out Of Range
    [Documentation]    Verify that UE ID 101 is rejected by the system.
    [Tags]             negative
    Attach UE 101
    Verify Error Message For UE ID Out Of Range

TC-003 Reject Duplicate UE 1 Attachment
    [Documentation]    Verify that attaching an already attached UE returns an error.
    [Tags]             negative
    Attach UE 1
    Attach UE 1
    Verify Error Message For Duplicate UE Attachment

TC-004 Detach UE 1 Successfully
    [Documentation]    Verify successful removal of UE from network.
    [Tags]             positive    detach
    Attach UE 1
    Detach UE 1
    Verify UE 1 Is Detached Successfully

TC-005 Reject Detach For Non-Existent UE 10
    [Documentation]    Verify error when detaching a UE that is not in the system.
    [Tags]             negative
    Detach UE 10
    Verify Error Message For Non-Existent UE

TC-006 Verify Default Bearer 9 Creation For UE 1
    [Documentation]    Requirement: "Podłączony do sieci UE automatycznie otrzymuje domyślny bearer o ID 9".
    [Tags]             compliance    positive
    Attach UE 1
    Retrieve Status Of UE 1
    # Verify ID 9 is present in the bearer list (implicit in traffic stats test)
    Retrieve Traffic Stats For UE 1 On Bearer 9
    Response Should Be Successful

# TC demonstrating defect DEF-002
TC-007 Support UE ID Boundary 0
    [Documentation]    Requirement: "zakres dostępnych UE: 0-100".
    [Tags]             compliance    boundary    bug-discovery
    Attach UE 0
    Verify UE 0 Is Attached Successfully

TC-008 Support UE ID Boundary 100
    [Documentation]    Requirement: "zakres dostępnych UE: 0-100".
    [Tags]             compliance    boundary
    Attach UE 100
    Verify UE 100 Is Attached Successfully






*** Settings ***
Resource          ../resources/epc_keywords.resource
Documentation     UE Attachment and Detachment tests based on documentation.
Suite Setup       Initialize Simulator Session
Suite Teardown    Reset Machine
Test Teardown     Reset Machine

*** Variables ***
${UE_ID}          1

*** Test Cases ***

TC-001: Attach UE Successfully
    [Documentation]    Requirement: Verify successful UE attachment.
    [Tags]             positive    attach
    Attach UE ${UE_ID}
    Verify UE ${UE_ID} Is Attached Successfully

TC-002: Reject UE ID Out Of Range
    [Documentation]    Verify that UE ID 101 is rejected by the system.
    [Tags]             negative
    Attach UE 101
    Response Should Match Status 422

TC-003: Reject Duplicate UE Attachment
    [Documentation]    Verify that attaching an already attached UE returns an error.
    [Tags]             negative
    Attach UE ${UE_ID}
    Attach UE ${UE_ID}
    Response Should Match Status 400

TC-004: Detach UE Successfully
    [Documentation]    Verify successful removal of UE from network.
    [Tags]             positive    detach
    Attach UE ${UE_ID}
    Detach UE ${UE_ID}
    Verify UE ${UE_ID} Is Detached Successfully

TC-005: Reject Detach For Non-Existent UE
    [Documentation]    Verify error when detaching a UE that is not in the system.
    [Tags]             negative
    Detach UE 10
    Response Should Match Status 400

TC-006: Verify Default Bearer 9 Creation
    [Documentation]    Requirement: "Podłączony do sieci UE automatycznie otrzymuje domyślny bearer o ID 9".
    [Tags]             compliance    positive
    Attach UE ${UE_ID}
    Retrieve Status Of UE ${UE_ID}
    # Verify ID 9 is present in the bearer list (implicit in traffic stats test)
    Retrieve Traffic Stats For UE ${UE_ID} On Bearer 9
    Response Should Be Successful

# TC demonstrating defect DEF-002
TC-007: Support UE ID Boundary 0
    [Documentation]    Requirement: "zakres dostępnych UE: 0-100".
    [Tags]             compliance    boundary    bug-discovery
    Attach UE 0
    Verify UE 0 Is Attached Successfully

TC-008: Support UE ID Boundary 100
    [Documentation]    Requirement: "zakres dostępnych UE: 0-100".
    [Tags]             compliance    boundary
    Attach UE 100
    Verify UE 100 Is Attached Successfully






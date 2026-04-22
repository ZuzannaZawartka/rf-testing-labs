*** Settings ***
Resource          ../resources/epc_keywords.resource
Documentation     UE Attachment and Detachment tests based on documentation.
Suite Setup       Reset Machine
Test Teardown     Reset Machine

*** Test Cases ***

TC-001: Attach UE Successfully
    [Documentation]    Requirement: Verify successful UE attachment.
    [Tags]             positive    attach
    Attach UE 1
    Verify UE 1 Attached Successfully

TC-002: Reject UE ID Out Of Range
    [Documentation]    Verify that UE ID 101 is rejected by the system.
    [Tags]             negative
    Attach UE 101
    Response Should Match Status 422

TC-003: Reject Duplicate UE Attachment
    [Documentation]    Verify that attaching an already attached UE returns an error.
    [Tags]             negative
    Attach UE 1
    Attach UE 1
    Response Should Match Status 400

TC-004: Detach UE Successfully
    [Documentation]    Verify successful removal of UE from network.
    [Tags]             positive    detach
    Attach UE 1
    Detach UE 1
    Verify UE 1 Detached Successfully

TC-005: Reject Detach For Non-Existent UE
    [Documentation]    Verify error when detaching a UE that is not in the system.
    [Tags]             negative
    Detach UE 1
    Response Should Match Status 400

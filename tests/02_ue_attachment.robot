*** Settings ***
Resource          ../resources/epc_keywords.resource
Documentation     UE Attachment and Detachment tests based on documentation.
Suite Setup       Reset Simulator
Test Teardown     Reset Simulator

*** Variables ***
${STATUS_ATTACHED}  attached

*** Test Cases ***

TC_001: Successful Attachment of UE
    [Documentation]    Requirement: Verify successful UE attachment.
    [Tags]             positive    attach
    Register device with ID "1"
    Device should be successfully attached

TC_002: Rejection of UE ID Out Of Range
    [Documentation]    Verify that UE ID 101 is rejected by the system.
    [Tags]             negative
    Register device with ID "101"
    Attempt should be rejected due to invalid input

TC_003: Rejection of Duplicate Attachment
    [Documentation]    Verify that attaching an already attached UE returns an error.
    [Tags]             negative
    Register device with ID "1"
    Register device with ID "1"
    Attempt should be rejected due to device already attached

TC_004: Successful UE Detachment
    [Documentation]    Verify successful removal of UE from network.
    [Tags]             positive    detach
    Register device with ID "1"
    Disconnect device with ID "1"
    Device should be successfully detached

TC_005: Detach Not Attached UE
    [Documentation]    Verify error when detaching a UE that is not in the system.
    [Tags]             negative
    Disconnect device with ID "1"
    Attempt should be rejected due to device not found

*** Keywords ***

Register device with ID "${ue_id}"
    Attach Device With ID "${ue_id}" To Network

Device should be successfully attached
    Response Status Should Be    200
    Response Should Contain Key With Value    status    attached

Attempt should be rejected due to invalid input
    Response Status Should Be    422

Attempt should be rejected due to device already attached
    Response Status Should Be    400

Disconnect device with ID "${ue_id}"
    Detach Device With ID "${ue_id}" From Network

Device should be successfully detached
    Response Status Should Be    200
    Response Should Contain Key With Value    status    detached

Attempt should be rejected due to device not found
    Response Status Should Be    400

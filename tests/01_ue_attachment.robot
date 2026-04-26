*** Settings ***
Documentation     UE attachment and detachment tests.
Resource          ../resources/epc_keywords.resource
Suite Setup       Initialize Simulator Session
Suite Teardown    Reset Simulator
Test Teardown     Reset Simulator

*** Test Cases ***

TC-001 Attach UE 1 To Network Successfully
    [Documentation]    Verify UE 1 is registered and receives attached status.
    [Tags]             attach    positive
    Attach UE 1
    Verify UE 1 Attached Successfully

TC-002 Reject Attach For UE 101 As Out Of Range
    [Documentation]    UE ID 101 exceeds the allowed range 0-100.
    ...                Verify the error message references the valid boundary values.
    [Tags]             attach    negative    boundary
    Attach UE 101
    Verify UE ID Rejected As Out Of Range

TC-003 Reject Second Attach For Already Attached UE 1
    [Documentation]    Verify that attaching UE 1 while it is already registered
    ...                returns a duplicate-attachment error.
    [Tags]             attach    negative
    Attach UE 1
    Attach UE 1
    Verify UE Attachment Rejected As Duplicate

TC-004 Detach Attached UE 1 Successfully
    [Documentation]    Verify UE 1 can be detached after a successful attach.
    ...                Attach is a prerequisite for detach, both operations are
    ...                combined to ensure correct state.
    [Tags]             detach    positive
    Attach UE 1
    Detach UE 1
    Verify UE 1 Detached Successfully

TC-005 Reject Detach For Non-Existent UE 10
    [Documentation]    Verify that detaching UE 10 which was never attached
    ...                returns a not-found error.
    [Tags]             detach    negative
    Detach UE 10
    Verify UE Detachment Rejected As Not Found

TC-006 Verify Default Bearer 9 Created Automatically For UE 1
    [Documentation]    Verify UE 1 receives default bearer 9 automatically on attach.
    [Tags]             attach    positive    compliance
    Attach UE 1
    Verify Default Bearer 9 Exists For UE 1

TC-007 Attach UE 0 At Lower Boundary Successfully
    [Documentation]    DEF-001, Verify UE ID 0 (lower boundary of range 0-100) is accepted.
    [Tags]             attach    positive    boundary
    Attach UE 0
    Verify UE 0 Attached Successfully

TC-008 Attach UE 100 At Upper Boundary Successfully
    [Documentation]    Verify UE ID 100 (upper boundary of range 0-100) is accepted.
    [Tags]             attach    positive    boundary
    Attach UE 100
    Verify UE 100 Attached Successfully

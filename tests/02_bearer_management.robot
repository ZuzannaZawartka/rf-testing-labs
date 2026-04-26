*** Settings ***
Documentation     Bearer management tests.
Resource          ../resources/epc_keywords.resource
Suite Setup       Initialize Simulator Session
Suite Teardown    Reset Simulator
Test Teardown     Reset Simulator

*** Test Cases ***

TC-009 Add Dedicated Bearer 3 To UE 5 Successfully
    [Documentation]    Verify bearer 3 can be added to attached UE 5.
    ...                Attach is required before any bearer operation, both steps
    ...                are combined intentionally.
    [Tags]             bearer    positive
    Attach UE 5
    Add Bearer 3 To UE 5
    Verify Bearer 3 Added To UE 5 Successfully

TC-010 Reject Bearer 999 As Out Of Range For UE 5
    [Documentation]    Verify bearer ID 999 is outside the allowed range 1-9 and
    ...                the error message references the valid boundary values.
    [Tags]             bearer    negative    boundary
    Attach UE 5
    Add Bearer 999 To UE 5
    Verify Bearer ID Rejected As Out Of Range

TC-011 Reject Adding Duplicate Bearer 3 To UE 5
    [Documentation]    Verify that adding bearer 3 a second time to UE 5
    ...                returns a duplicate-bearer error.
    [Tags]             bearer    negative
    Attach UE 5
    Add Bearer 3 To UE 5
    Add Bearer 3 To UE 5
    Verify Bearer Addition Rejected As Duplicate

TC-012 Retrieve Status For UE 5 With Active Bearer 3
    [Documentation]    Verify the UE status endpoint returns success after bearer 3
    ...                is added to UE 5.
    [Tags]             bearer    positive
    Attach UE 5
    Add Bearer 3 To UE 5
    Retrieve UE 5 Status
    Verify UE 5 Status Retrieved Successfully

TC-013 Reject Deletion Of Default Bearer 9 For UE 5
    [Documentation]    Verify default bearer 9 cannot be removed from UE 5.
    [Tags]             bearer    negative    compliance
    Attach UE 5
    Remove Bearer 9 From UE 5
    Verify Default Bearer Deletion Rejected

TC-014 Reject Bearer 10 As Out Of Range When Adding To UE 5
    [Documentation]    Verify bearer ID 10 exceeds the upper boundary of range 1-9
    ...                and is rejected with a range error.
    [Tags]             bearer    negative    boundary
    Attach UE 5
    Add Bearer 10 To UE 5
    Verify Bearer ID Rejected As Out Of Range

TC-015 Reject Deletion Of Bearer 10 As Out Of Range For UE 5
    [Documentation]    DEF-002, Verify deleting bearer 10 (above upper boundary 9)
    ...                returns a range error rather than a not-found error.
    [Tags]             bearer    negative    boundary
    Attach UE 5
    Remove Bearer 10 From UE 5
    Verify Bearer ID Rejected As Out Of Range

TC-016 Remove Dedicated Bearer 3 From UE 5 Successfully
    [Documentation]    Verify dedicated bearer 3 can be removed from UE 5.
    ...                Default bearer 9 is unaffected.
    [Tags]             bearer    positive
    Attach UE 5
    Add Bearer 3 To UE 5
    Remove Bearer 3 From UE 5
    Verify Bearer 3 Removed From UE 5 Successfully

TC-017 Reject Deletion Of Never-Added Bearer 3 For UE 5
    [Documentation]    Verify that removing bearer 3 from UE 5 when it was never
    ...                added returns a not-found error.
    [Tags]             bearer    negative
    Attach UE 5
    Remove Bearer 3 From UE 5
    Verify Bearer Rejected As Not Found

TC-018 Reject Adding Bearer 0 As Below Lower Boundary For UE 30
    [Documentation]    Verify bearer ID 0 is below the allowed range 1-9
    ...                and is rejected with a validation error referencing the minimum value.
    [Tags]             bearer    negative    boundary
    Attach UE 30
    Add Bearer 0 To UE 30
    Verify Bearer ID Rejected As Out Of Range

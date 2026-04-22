*** Settings ***
Resource          ../resources/epc_keywords.resource
Documentation     Bearer Management tests.
Suite Setup       Initialize Simulator Session
Suite Teardown    Reset Machine
Test Teardown     Reset Machine

*** Test Cases ***

TC-009 Add Bearer 3 To Attached UE 5
    [Documentation]    Verify successful bearer addition to attached UE.
    [Tags]             bearer    positive
    Attach UE 5
    Add Bearer 3 To UE 5
    Response Should Be Successful


TC-010 Reject Bearer ID 999 Out Of Range For UE 5
    [Documentation]    Verify that bearer ID 999 out of range is rejected.
    [Tags]             bearer    negative
    Attach UE 5
    Add Bearer 999 To UE 5
    Verify Error Message For Bearer ID Out Of Range


TC-011 Reject Duplicate Bearer 3 For UE 5
    [Documentation]    Verify that adding the same bearer twice returns an error.
    [Tags]             bearer    negative
    Attach UE 5
    Add Bearer 3 To UE 5
    Add Bearer 3 To UE 5
    Verify Error Message Contains    already exists


TC-012 Retrieve Bearers Of Attached UE 5
    [Documentation]    Verify that bearers of attached UE can be retrieved.
    [Tags]             bearer    positive
    Attach UE 5
    Add Bearer 3 To UE 5
    Retrieve Status Of UE 5
    Response Should Be Successful


TC-013 Prevent Deletion Of Default Bearer 9 For UE 5
    [Documentation]    Requirement: "Nie ma możliwości usunięcia domyślnego bearera".
    [Tags]             compliance    negative
    Attach UE 5
    Remove Bearer 9 From UE 5
    Verify Error Message For Deleting Default Bearer


TC-014 Reject Bearer ID 10 Outside Range For UE 5
    [Documentation]    Requirement: "zakres bearerów dla UE: 1-9".
    [Tags]             compliance    negative
    Attach UE 5
    # Bearer 10 is outside the documented range 1-9
    Add Bearer 10 To UE 5
    Verify Error Message For Bearer ID Out Of Range


# TC demonstrating defect DEF-003
TC-015 Reject Deletion of Bearer ID 10 Outside Range For UE 5
    [Documentation]    Requirement: "zakres bearerów dla UE: 1-9" - bearer 10 is outside range.
    [Tags]             bearer    negative    boundary
    Attach UE 5
    Remove Bearer 10 From UE 5
    Verify Error Message For Bearer ID Out Of Range

TC-016 Successful Deletion Of Dedicated Bearer
    [Documentation]    Verify successful removal of a dedicated bearer.
    [Tags]             bearer    positive
    Attach UE 5
    Add Bearer 3 To UE 5
    Remove Bearer 3 From UE 5
    Response Should Be Successful


TC-017 Reject Deletion Of Inactive Bearer Within Range
    [Documentation]    Verify that deleting an inactive bearer (but within range 1-9) returns "not found".
    [Tags]             bearer    negative
    Attach UE 5
    Remove Bearer 3 From UE 5
    Verify Error Message Contains    Bearer not found


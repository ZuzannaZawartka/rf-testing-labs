*** Settings ***
Resource          ../resources/epc_keywords.resource
Documentation     Bearer Management tests.
Suite Setup       Initialize Simulator Session
Suite Teardown    Reset Machine
Test Teardown     Reset Machine

*** Variables ***
${UE_ID}          5
${BEARER_ID}      3

*** Test Cases ***

TC-009: Add Bearer To Attached UE
    [Documentation]    Verify successful bearer addition to attached UE.
    [Tags]             bearer    positive
    Attach UE ${UE_ID}
    Add Bearer ${BEARER_ID} To UE ${UE_ID}
    Response Should Be Successful


TC-010: Reject Bearer ID Out Of Range
    [Documentation]    Verify that bearer ID out of range is rejected.
    [Tags]             bearer    negative
    Attach UE ${UE_ID}
    Add Bearer 999 To UE ${UE_ID}
    Response Should Match Status 422


TC-011: Reject Duplicate Bearer
    [Documentation]    Verify that adding the same bearer twice returns an error.
    [Tags]             bearer    negative
    Attach UE ${UE_ID}
    Add Bearer ${BEARER_ID} To UE ${UE_ID}
    Add Bearer ${BEARER_ID} To UE ${UE_ID}
    Response Should Match Status 400


TC-012: Retrieve Bearers Of Attached UE
    [Documentation]    Verify that bearers of attached UE can be retrieved.
    [Tags]             bearer    positive
    Attach UE ${UE_ID}
    Add Bearer ${BEARER_ID} To UE ${UE_ID}
    Retrieve Status Of UE ${UE_ID}
    Response Should Be Successful


TC-013: Prevent Deletion Of Default Bearer
    [Documentation]    Requirement: "Nie ma możliwości usunięcia domyślnego bearera".
    [Tags]             compliance    negative
    Attach UE ${UE_ID}
    Remove Bearer 9 From UE ${UE_ID}
    # Should fail (400) according to documentation.
    Response Should Match Status 400


TC-014: Reject Bearer ID Outside Range
    [Documentation]    Requirement: "zakres bearerów dla UE: 1-9".
    [Tags]             compliance    negative
    Attach UE ${UE_ID}
    # Bearer 10 is outside the documented range 1-9
    Add Bearer 10 To UE ${UE_ID}
    Response Should Match Status 422





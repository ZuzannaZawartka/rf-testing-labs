*** Settings ***
Resource          ../resources/epc_keywords.resource
Documentation     Bearer Management tests.
Suite Setup       Initialize Simulator Session
Suite Teardown    Reset Machine
Test Teardown     Reset Machine

*** Variables ***
${VALID_UE}        5
${VALID_BEARER}    3

*** Test Cases ***

TC-006: Add Bearer To Attached UE
    [Documentation]    Verify successful bearer addition to attached UE.
    [Tags]             bearer    positive
    Attach UE ${VALID_UE}
    Add Bearer ${VALID_BEARER} To UE ${VALID_UE}
    Response Should Be Successful

TC-007: Reject Bearer ID Out Of Range
    [Documentation]    Verify that bearer ID out of range is rejected.
    [Tags]             bearer    negative
    Attach UE ${VALID_UE}
    Add Bearer 999 To UE ${VALID_UE}
    Response Should Match Status 422

TC-008: Reject Duplicate Bearer
    [Documentation]    Verify that adding the same bearer twice returns an error.
    [Tags]             bearer    negative
    Attach UE ${VALID_UE}
    Add Bearer ${VALID_BEARER} To UE ${VALID_UE}
    Add Bearer ${VALID_BEARER} To UE ${VALID_UE}
    Response Should Match Status 400

TC-009: Retrieve Bearers Of Attached UE
    [Documentation]    Verify that bearers of attached UE can be retrieved.
    [Tags]             bearer    positive
    Attach UE ${VALID_UE}
    Add Bearer ${VALID_BEARER} To UE ${VALID_UE}
    Get Status Of UE ${VALID_UE}
    Response Should Be Successful

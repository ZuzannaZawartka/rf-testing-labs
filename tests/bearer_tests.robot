*** Settings ***
Resource          ../resources/epc_keywords.resource
Documentation     Bearer add/remove tests.
Suite Setup       Setup Simulator Session
Suite Teardown    Reset Simulator
Test Teardown     Reset Simulator

*** Variables ***
${VALID_UE}        ${5}
${VALID_BEARER}    ${3}

*** Test Cases ***

TC_01 Add Bearer To Attached UE
    [Documentation]    Verify successful bearer addition to attached UE.
    [Tags]             bearer    positive
    Attach UE With ID    ${VALID_UE}
    Add Bearer To UE    ${VALID_UE}    ${VALID_BEARER}
    Bearer Should Be Successfully Added

TC_02 Add Bearer Out Of Range Returns Error
    [Documentation]    Verify that bearer ID out of range is rejected.
    [Tags]             bearer    negative
    Attach UE With ID    ${VALID_UE}
    Add Bearer To UE    ${VALID_UE}    999
    Attempt Should Be Rejected Due To Invalid Input

TC_03 Add Duplicate Bearer Returns Error
    [Documentation]    Verify that adding the same bearer twice returns an error.
    [Tags]             bearer    negative
    Attach UE With ID    ${VALID_UE}
    Add Bearer To UE    ${VALID_UE}    ${VALID_BEARER}
    Add Bearer To UE    ${VALID_UE}    ${VALID_BEARER}
    Attempt Should Be Rejected Due To Bearer Already Added

TC_04 Get Bearers Of Attached UE
    [Documentation]    Verify that bearers of attached UE can be retrieved.
    [Tags]             bearer    positive
    Attach UE With ID    ${VALID_UE}
    Add Bearer To UE    ${VALID_UE}    ${VALID_BEARER}
    Get Bearers Of UE    ${VALID_UE}
    Bearer List Should Be Returned

*** Keywords ***

Attach UE With ID
    [Arguments]    ${ue_id}
    Attach Device With ID "${ue_id}" To Network

Add Bearer To UE
    [Arguments]    ${ue_id}    ${bearer_id}
    Add Bearer With ID "${bearer_id}" To UE "${ue_id}"

Get Bearers Of UE
    [Arguments]    ${ue_id}
    Get Status Of Device "${ue_id}"

Bearer Should Be Successfully Added
    Response Status Should Be    200

Attempt Should Be Rejected Due To Invalid Input
    Response Status Should Be    422

Attempt Should Be Rejected Due To Bearer Already Added
    Response Status Should Be    400

Bearer List Should Be Returned
    Response Status Should Be    200

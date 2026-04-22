*** Settings ***
Resource          ../resources/epc_keywords.resource
Documentation     Traffic start tests based on documentation.
Suite Setup       Setup Simulator Session

*** Variables ***
${VALID_UE}        ${5}
${VALID_BEARER}    ${9}
${SPEED_MBPS}      ${10}

*** Test Cases ***

TC_01 Rozpoczęcie transferu z prawidłową prędkością zwraca 200 i poprawne dane
    [Tags]       traffic    start    happy-path    smoke
    [Setup]      Full Setup With Bearer    ${VALID_UE}    ${VALID_BEARER}
    [Teardown]   Full Teardown With Bearer    ${VALID_UE}    ${VALID_BEARER}
    Start Traffic On Bearer "${VALID_BEARER}" Of UE "${VALID_UE}" With Speed "${SPEED_MBPS}"
    Response Status Should Be                200
    Response Should Contain UE "${VALID_UE}" And Bearer "${VALID_BEARER}"
    Response Field "target_bps" Should Be Greater Than ${0}

*** Keywords ***

# --- Environment setup/teardown ---

Full Setup With Bearer
    [Documentation]    Attach UE and add bearer so traffic endpoint is reachable
    [Arguments]    ${ue_id}    ${bearer_id}
    Attach Device With ID "${ue_id}" To Network
    Add Bearer With ID "${bearer_id}" To UE "${ue_id}"

Full Teardown With Bearer
    [Documentation]    Stop any running traffic, remove bearer, detach UE
    [Arguments]    ${ue_id}    ${bearer_id}
    Stop Traffic Silently On Bearer "${bearer_id}" Of UE "${ue_id}"
    Remove Bearer With ID "${bearer_id}" From UE "${ue_id}"
    Detach Device With ID "${ue_id}" From Network

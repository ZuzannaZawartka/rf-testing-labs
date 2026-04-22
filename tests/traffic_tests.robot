*** Settings ***
Resource          ../resources/epc_keywords.resource
Documentation     Traffic start, stop and stats tests based on documentation.
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

TC_02 Zatrzymanie aktywnego transferu zwraca 200 i poprawne dane
    [Tags]       traffic    stop    happy-path    smoke
    [Setup]      Full Setup With Active Traffic    ${VALID_UE}    ${VALID_BEARER}    ${SPEED_MBPS}
    [Teardown]   Full Teardown With Bearer    ${VALID_UE}    ${VALID_BEARER}
    Stop Traffic On Bearer "${VALID_BEARER}" Of UE "${VALID_UE}"
    Response Status Should Be                200
    Response Should Contain UE "${VALID_UE}" And Bearer "${VALID_BEARER}"

TC_03 Statystyki aktywnego transferu zwracają 200 i poprawną odpowiedź
    [Tags]       traffic    stats    happy-path    smoke
    [Setup]      Full Setup With Active Traffic    ${VALID_UE}    ${VALID_BEARER}    ${SPEED_MBPS}
    [Teardown]   Full Teardown With Bearer    ${VALID_UE}    ${VALID_BEARER}
    Get Traffic Stats On Bearer "${VALID_BEARER}" Of UE "${VALID_UE}"
    Response Status Should Be                200
    Response Should Contain UE "${VALID_UE}" And Bearer "${VALID_BEARER}"
    Response Field "protocol" Should Equal    tcp
    Response Field "target_bps" Should Be Greater Than ${0}
    Response Field "tx_bps" Should Be Present
    Response Field "rx_bps" Should Be Present
    Response Field "duration" Should Be Greater Or Equal ${0}

*** Keywords ***

# --- Environment setup/teardown ---

Full Setup With Bearer
    [Documentation]    Attach UE and add bearer so traffic endpoint is reachable
    [Arguments]    ${ue_id}    ${bearer_id}
    Attach Device With ID "${ue_id}" To Network
    Add Bearer With ID "${bearer_id}" To UE "${ue_id}"

Full Setup With Active Traffic
    [Documentation]    Attach UE, add bearer and start traffic so stop/stats can be tested
    [Arguments]    ${ue_id}    ${bearer_id}    ${mbps}
    Attach Device With ID "${ue_id}" To Network
    Add Bearer With ID "${bearer_id}" To UE "${ue_id}"
    Start Traffic On Bearer "${bearer_id}" Of UE "${ue_id}" With Speed "${mbps}"

Full Teardown With Bearer
    [Documentation]    Stop any running traffic, remove bearer, detach UE
    [Arguments]    ${ue_id}    ${bearer_id}
    Stop Traffic Silently On Bearer "${bearer_id}" Of UE "${ue_id}"
    Remove Bearer With ID "${bearer_id}" From UE "${ue_id}"
    Detach Device With ID "${ue_id}" From Network

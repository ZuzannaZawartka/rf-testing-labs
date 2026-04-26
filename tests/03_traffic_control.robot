*** Settings ***
Documentation     Traffic control and data transfer tests.
Resource          ../resources/epc_keywords.resource
Suite Teardown    Reset Simulator
Test Teardown     Reset Simulator

*** Test Cases ***

TC-019 Start 10 Mbps Traffic On UE 5 Default Bearer 9 Successfully
    [Documentation]    Verify 10 Mbps DL traffic starts on default bearer 9 of UE 5.
    ...                Actual throughput must be within around 10% of the requested value
    ...                (9–11 Mbps). Bearer 9 is created automatically on attach.
    ...                Attach is a prerequisite for any traffic operation.
    [Tags]             traffic    start    positive
    Attach UE 5
    Start Traffic On UE 5 Bearer 9 At 10 Mbps
    Verify Traffic Started At Around 10 Mbps

TC-020 Stop Active Traffic On UE 5 Default Bearer 9 Successfully
    [Documentation]    Verify active traffic on UE 5 bearer 9 can be stopped.
    ...                Attach and traffic start are prerequisites, the setup
    ...                helper combines all required steps.
    [Tags]             traffic    stop    positive
    [Setup]    Prepare Attached UE 5 With Active Traffic On Bearer 9 At 10 Mbps
    Stop Traffic On UE 5 Bearer 9
    Verify Traffic Stopped On UE 5 Bearer 9 Successfully

TC-021 Retrieve Traffic Stats For UE 5 Bearer 9 With Protocol And Field Verification
    [Documentation]    Verify traffic stats for UE 5 bearer 9 contain the correct protocol,
    ...                throughput within +-10% of 10 Mbps, and both tx_bps and rx_bps fields.
    ...                Attach and traffic start are prerequisites, the setup
    ...                helper combines all required steps.
    [Tags]             traffic    stats    positive
    [Setup]    Prepare Attached UE 5 With Active Traffic On Bearer 9 At 10 Mbps
    Retrieve Traffic Stats For UE 5 Bearer 9
    Verify Traffic Uses Protocol    udp
    Verify Traffic Started At Around 10 Mbps
    Verify Field tx_bps Is Present In Response
    Verify Field rx_bps Is Present In Response

TC-022 Start 100 Mbps Traffic At Maximum Limit On UE 5 Bearer 9 Successfully
    [Documentation]    Verify 100 Mbps (the documented maximum for DL) is accepted and
    ...                the measured throughput is within +-10% of the maximum.
    ...                Attach is a prerequisite, bearer 9 is the default bearer.
    [Tags]             traffic    positive    compliance
    Attach UE 5
    Start Traffic On UE 5 Bearer 9 At 100 Mbps
    Verify Traffic Started At Around 100 Mbps

TC-023 Reject Traffic Start On Inactive Bearer 5 For UE 5
    [Documentation]    Verify starting traffic on bearer 5, which was never added to UE 5,
    ...                returns a bearer-not-found error.
    ...                UE 5 must be attached first, bearer 5 is never created.
    [Tags]             traffic    negative    compliance
    Attach UE 5
    Start Traffic On UE 5 Bearer 5 At 10 Mbps
    Verify Traffic Rejected Due To Inactive Bearer

TC-024 Reject 101 Mbps Traffic As Exceeding 100 Mbps Limit For UE 5 Bearer 9
    [Documentation]    DEF-003, Verify 101 Mbps is rejected when submitted using the Mbps parameter.
    ...                The error must reference the maximum throughput limit.
    ...                UE 5 must be attached before traffic can be started.
    [Tags]             traffic    negative    compliance
    Attach UE 5
    Start Traffic On UE 5 Bearer 9 At 101 Mbps
    Verify Traffic Rejected As Exceeding Maximum Limit

TC-025 Reject Negative Throughput Value Of -10 Mbps For UE 10 Bearer 9
    [Documentation]    DEF-004, Verify a negative throughput value is rejected with a validation error.
    ...                UE 10 must be attached, bearer 9 is the default bearer.
    [Tags]             traffic    negative    boundary
    Attach UE 10
    Start Traffic On UE 10 Bearer 9 At -10 Mbps
    Verify Throughput Value Rejected As Invalid

TC-026 Reject 101000 kbps Traffic As Exceeding 100 Mbps Limit For UE 5 Bearer 9
    [Documentation]    DEF-005, Verify 101 000 kbps (around 101 Mbps) is rejected when
    ...                submitted using the kbps parameter. The error must reference
    ...                the maximum throughput limit.
    [Tags]             traffic    negative    compliance
    Attach UE 5
    Start Traffic On UE 5 Bearer 9 At 101000 kbps
    Verify Traffic Rejected As Exceeding Maximum Limit

TC-027 Reject Second Stream Causing Aggregate To Exceed 100 Mbps On UE 5
    [Documentation]    DEF-006, Verify the 100 Mbps aggregate DL limit is enforced across
    ...                bearers. First stream (60 Mbps on bearer 9) must be accepted, second
    ...                stream (60 Mbps on bearer 1) must be rejected because the total
    ...                would reach 120 Mbps.
    ...                Bearer 1 must be explicitly added; only bearer 9 is created
    ...                automatically on attach.
    [Tags]             traffic    negative    compliance
    Attach UE 5
    Add Bearer 1 To UE 5
    Start Traffic On UE 5 Bearer 9 At 60 Mbps
    Verify Traffic Started At Around 60 Mbps
    Start Traffic On UE 5 Bearer 1 At 60 Mbps
    Verify Traffic Rejected As Exceeding Maximum Limit

TC-028 Verify Default kbps Unit Returned In Traffic Stats For UE 5 Bearer 9
    [Documentation]    Verify traffic stats are returned in kbps by default,
    ...                without passing an explicit unit parameter.
    ...                Attach and traffic start are prerequisites.
    [Tags]             traffic    stats    compliance
    [Setup]    Prepare Attached UE 5 With Active Traffic On Bearer 9 At 10 Mbps
    Retrieve Traffic Stats For UE 5 Bearer 9
    Verify Traffic Stats Returned In kbps

TC-029 Stop All Traffic Across All Bearers For UE 5 Successfully
    [Documentation]    DEF-007, Verify the stop-all-traffic endpoint terminates traffic
    ...                on all active bearers simultaneously for UE 5.
    ...                Bearer 1 must be explicitly added, only bearer 9 is created
    ...                automatically on attach.
    [Tags]             traffic    positive    compliance
    Attach UE 5
    Add Bearer 1 To UE 5
    Start Traffic On UE 5 Bearer 9 At 10 Mbps
    Start Traffic On UE 5 Bearer 1 At 5 Mbps
    Stop All Traffic For UE 5
    Verify All Traffic Stopped For UE 5 Successfully

TC-030 Start TCP Traffic On UE 5 Bearer 9 Successfully
    [Documentation]    DEF-008, Verify the traffic endpoint accepts the TCP protocol.
    ...                The API documentation does not mention a `protocol` parameter, but
    ...                the request schema appears to require it and only allows `udp` or
    ...                `tcp`. This test validates that `tcp` is accepted, indicating a
    ...                likely documentation defect or missing requirement. Attach is a
    ...                prerequisite, and bearer 9 is the default bearer.
    [Tags]             traffic    positive    protocol    compliance
    Attach UE 5
    Start Traffic On UE 5 Bearer 9 Protocol tcp At 10 Mbps
    Retrieve Traffic Stats For UE 5 Bearer 9
    Verify Traffic Uses Protocol    tcp

TC-031 Retrieve Aggregate Traffic Stats For UE 5 Across Multiple Bearers
    [Documentation]    DEF-009, Verify traffic stats can be retrieved as an aggregate for all
    ...                active bearers of a given UE.
    [Tags]             traffic    stats    positive
    Attach UE 5
    Add Bearer 1 To UE 5
    Start Traffic On UE 5 Bearer 9 At 10 Mbps
    Start Traffic On UE 5 Bearer 1 At 5 Mbps
    Retrieve Aggregate Traffic Stats For UE 5
    Verify Traffic Stats Returned In kbps

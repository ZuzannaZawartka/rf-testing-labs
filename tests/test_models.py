import pytest
from pydantic import ValidationError

from epc.models import UEState, StartTrafficRequest, BearerConfig


def test_ue_state_initializes_with_empty_collections():
    ue = UEState(ue_id=1)
    
    assert ue.bearers == {}
    assert ue.stats == {}
    assert ue.ue_id == 1


def test_ue_id_out_of_range():
    with pytest.raises(ValidationError):
        UEState(ue_id=101)


def test_start_traffic_multiple_throughputs():
    with pytest.raises(ValidationError):
        StartTrafficRequest(protocol="tcp", Mbps=5.0, kbps=1000.0)


def test_start_traffic_zero_throughputs():
    with pytest.raises(ValidationError, match="exactly one throughput value"):
        StartTrafficRequest(protocol="udp")


def test_bearer_protocol_must_be_tcp_or_udp():
    with pytest.raises(ValidationError):
        BearerConfig(bearer_id=5, protocol="ftp")


def test_bearer_id_out_of_range():
    with pytest.raises(ValidationError):
        BearerConfig(bearer_id=0)
        
    with pytest.raises(ValidationError):
        BearerConfig(bearer_id=10)


@pytest.mark.parametrize("throughput_kwargs,expected_bps", [
    ({"Mbps": 5.0}, 5_000_000),
    ({"kbps": 2500.0}, 2_500_000),
    ({"bps": 123.0}, 123),
])
def test_start_traffic_request_normalizes_throughput(throughput_kwargs, expected_bps):
    req = StartTrafficRequest(protocol="tcp", **throughput_kwargs)
    assert req.target_bps() == expected_bps

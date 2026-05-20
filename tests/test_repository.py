# test repository

from epc.models import BearerConfig, ThroughputStats
import pytest

def test_ue_exists_after_attach(repo):
    assert repo.ue_exists(9) is False
    repo.attach_ue(9)
    assert repo.ue_exists(9) is True

def test_detach_removes_ue(repo):
    repo.attach_ue(1)
    repo.detach_ue(1)
    assert repo.ue_exists(1) is False

def test_list_ues_returns_attached(repo):
    repo.attach_ue(2)
    repo.attach_ue(5)
    assert list(repo.list_ues()) == [2, 5]

def test_add_bearer_appears_in_state(repo):
    repo.attach_ue(1)
    repo.add_bearer(1, 3)
    state = repo.get_ue(1)
    assert 3 in state.bearers

def test_delete_bearer_removes_it(repo):
    repo.attach_ue(1)
    repo.add_bearer(1, 3)
    repo.delete_bearer(1, 3)
    state = repo.get_ue(1)
    assert 3 not in state.bearers

def test_attach_creates_default_bearer_9(repo):
    repo.attach_ue(1)
    state = repo.get_ue(1)
    assert 9 in state.bearers

def test_update_bearer_persists_protocol(repo):
    repo.attach_ue(1)
    repo.update_bearer(1, BearerConfig(bearer_id=9, protocol="udp", target_bps=1000))
    state = repo.get_ue(1)
    assert state.bearers[9].protocol == "udp"

def test_cannot_delete_default_bearer(repo):
    repo.attach_ue(1)
    with pytest.raises(ValueError, match="Cannot remove default bearer"):
        repo.delete_bearer(1, 9)

def test_update_stats_persists_bytes(repo):
    repo.attach_ue(1)
    repo.update_stats(1, ThroughputStats(bearer_id=9, ue_id=1, bytes_tx=4096))
    state = repo.get_ue(1)
    assert state.stats[9].bytes_tx == 4096

def test_reset_all_removes_all_ues(repo):
    repo.attach_ue(1)
    repo.attach_ue(2)
    repo.reset_all()
    assert list(repo.list_ues()) == []

import pytest
from fastapi import HTTPException

from epc.api import (
    attach_ue, detach_ue, list_ues, delete_bearer,
    get_ue, add_bearer, start_traffic, reset_all
)
from epc.models import AttachUERequest, AddBearerRequest, StartTrafficRequest


def test_api_list_ues_empty(repo):
    response = list_ues(repo=repo)
    assert response.ues == []


@pytest.mark.parametrize("ue_id", [1, 50, 100])
def test_api_attach_success(repo, ue_id):
    body = AttachUERequest(ue_id=ue_id)
    response = attach_ue(body=body, repo=repo)
    assert response.status == "attached"
    assert response.ue_id == ue_id


def test_api_attach_duplicate_raises_400(repo_with_ue):
    body = AttachUERequest(ue_id=1)
    with pytest.raises(HTTPException) as exc:
        attach_ue(body=body, repo=repo_with_ue)
    assert exc.value.status_code == 400


def test_api_detach_not_found_raises_400(repo):
    with pytest.raises(HTTPException) as exc:
        detach_ue(ue_id=99, repo=repo)
    assert exc.value.status_code == 400


def test_api_delete_bearer_not_found_raises_400(repo_with_ue):
    with pytest.raises(HTTPException) as exc:
        delete_bearer(ue_id=1, bearer_id=5, repo=repo_with_ue)
    assert exc.value.status_code == 400


def test_api_get_ue_returns_state(repo_with_ue):
    response = get_ue(ue_id=1, repo=repo_with_ue)
    assert 9 in response.bearers
    assert response.ue_id == 1


def test_api_add_bearer_success(repo_with_ue):
    body = AddBearerRequest(bearer_id=5)
    response = add_bearer(ue_id=1, body=body, repo=repo_with_ue)
    assert response.status == "bearer_added"
    assert response.bearer_id == 5


def test_api_start_traffic_missing_bearer_raises_400(repo_with_ue):
    body = StartTrafficRequest(protocol="udp", Mbps=10)
    with pytest.raises(HTTPException) as exc:
        start_traffic(ue_id=1, bearer_id=5, body=body, repo=repo_with_ue)
    assert exc.value.status_code == 400


def test_api_reset_all_clears_state(repo_with_ue):
    assert len(list_ues(repo=repo_with_ue).ues) == 1
    response = reset_all(repo=repo_with_ue)
    assert response.status == "reset"
    assert len(list_ues(repo=repo_with_ue).ues) == 0

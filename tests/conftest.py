import os
import tempfile

import pytest
from starlette.testclient import TestClient

import epc.api as api_mod
import epc.traffic as traffic_mod
from epc.db import EPCRepository
from main import app


@pytest.fixture(autouse=True)
def reset_singletons():
    traffic_mod.traffic_manager = None
    api_mod._repo_singleton = None
    yield
    traffic_mod.traffic_manager = None
    api_mod._repo_singleton = None


@pytest.fixture
def repo():
    fd, db_path = tempfile.mkstemp(suffix=".db")
    os.close(fd)
    try:
        yield EPCRepository(db_path)
    finally:
        try:
            os.unlink(db_path)
        except OSError:
            pass

@pytest.fixture
def repo_with_ue(repo):
    from epc.api import attach_ue
    from epc.models import AttachUERequest
    attach_ue(body=AttachUERequest(ue_id=1), repo=repo)
    return repo

@pytest.fixture
def client(tmp_path):
    traffic_mod.traffic_manager = None
    api_mod._repo_singleton = None

    repo = EPCRepository(str(tmp_path / "test.db"))
    app.dependency_overrides[api_mod.get_repo] = lambda: repo

    yield TestClient(app)

    app.dependency_overrides.clear()
    traffic_mod.traffic_manager = None
    api_mod._repo_singleton = None


@pytest.fixture
def client_with_ue(client):
    client.post("/ues", json={"ue_id": 1})
    return client


@pytest.fixture
def client_with_bearer(client_with_ue):
    client_with_ue.post("/ues/1/bearers", json={"bearer_id": 5})
    return client_with_ue
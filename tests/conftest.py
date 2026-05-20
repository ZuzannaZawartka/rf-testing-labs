import os
import tempfile

import pytest

import epc.api as api_mod
import epc.traffic as traffic_mod
from epc.db import EPCRepository


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

def test_attach_ue_returns_attached_status(client):
    response = client.post("/ues", json={"ue_id": 10})

    assert response.status_code == 200
    assert response.json() == {
        "status": "attached",
        "ue_id": 10,
    }


def test_attach_ue_out_of_range_returns_422(client):
    assert client.post("/ues", json={"ue_id": 0}).status_code == 422
    assert client.post("/ues", json={"ue_id": 101}).status_code == 422


def test_attach_duplicate_ue_returns_400(client_with_ue):
    response = client_with_ue.post("/ues", json={"ue_id": 1})

    assert response.status_code == 400
    assert response.json()["detail"] == "UE already attached"


def test_list_ues_reflects_attached_ues(client):
    client.post("/ues", json={"ue_id": 3})
    client.post("/ues", json={"ue_id": 7})

    response = client.get("/ues")

    assert response.status_code == 200
    assert sorted(response.json()["ues"]) == [3, 7]


def test_detach_ue_removes_it_from_list(client_with_ue):
    response = client_with_ue.delete("/ues/1")

    assert response.status_code == 200

    list_response = client_with_ue.get("/ues")

    assert 1 not in list_response.json()["ues"]


def test_detach_unknown_ue_returns_400(client):
    response = client.delete("/ues/99")

    assert response.status_code == 400
    assert response.json()["detail"] == "UE not found"


def test_add_bearer_appears_in_ue_state(client_with_ue):
    response = client_with_ue.post(
        "/ues/1/bearers",
        json={"bearer_id": 3},
    )

    assert response.status_code == 200

    ue_response = client_with_ue.get("/ues/1")

    assert "3" in ue_response.json()["bearers"]


def test_delete_default_bearer_returns_400(client_with_ue):
    response = client_with_ue.delete("/ues/1/bearers/9")

    assert response.status_code == 400
    assert response.json()["detail"] == "Cannot remove default bearer"


def test_start_traffic_returns_correct_target_bps(client_with_bearer):
    response = client_with_bearer.post(
        "/ues/1/bearers/5/traffic",
        json={
            "protocol": "udp",
            "Mbps": 10,
        },
    )

    assert response.status_code == 200
    assert response.json()["target_bps"] == 10_000_000


def test_start_traffic_invalid_protocol_returns_422(client_with_bearer):
    response = client_with_bearer.post(
        "/ues/1/bearers/5/traffic",
        json={
            "protocol": "ftp",
            "Mbps": 1,
        },
    )

    assert response.status_code == 422


def test_stop_traffic_returns_traffic_stopped_status(client_with_bearer):
    client_with_bearer.post(
        "/ues/1/bearers/5/traffic",
        json={
            "protocol": "tcp",
            "Mbps": 1,
        },
    )

    response = client_with_bearer.delete("/ues/1/bearers/5/traffic")

    assert response.status_code == 200
    assert response.json()["status"] == "traffic_stopped"

def test_ues_stats_scope_and_counts(client_with_ue):
    client_with_ue.post("/ues", json={"ue_id": 2})

    response = client_with_ue.get("/ues/stats")

    body = response.json()

    assert response.status_code == 200
    assert body["scope"] == "all"
    assert body["ue_count"] == 2
    assert "total_tx_bps" in body
    assert "total_rx_bps" in body


def test_ues_stats_unknown_ue_returns_400(client):
    response = client.get("/ues/stats?ue_id=99")

    assert response.status_code == 400
    assert response.json()["detail"] == "UE not found"

def test_reset_clears_all_ues(client_with_ue):
    response = client_with_ue.post("/reset")

    assert response.status_code == 200

    list_response = client_with_ue.get("/ues")

    assert list_response.json()["ues"] == []

def test_full_lifecycle_attach_bearer_traffic_detach(client):
    assert client.post("/ues", json={"ue_id": 5}).status_code == 200

    assert client.post(
        "/ues/5/bearers",
        json={"bearer_id": 3},
    ).status_code == 200

    assert client.post(
        "/ues/5/bearers/3/traffic",
        json={
            "protocol": "udp",
            "Mbps": 5,
        },
    ).status_code == 200

    assert client.delete(
        "/ues/5/bearers/3/traffic"
    ).status_code == 200

    assert client.delete("/ues/5").status_code == 200

    list_response = client.get("/ues")

    assert 5 not in list_response.json()["ues"]
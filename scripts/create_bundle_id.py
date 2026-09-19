#!/usr/bin/env python3
"""Garante que o bundle ID br.com.swingbrasilia.fun existe no App Store Connect.

Se já existir, apenas imprime o resource ID. Caso contrário, cria e imprime.
"""
import base64
import json
import time
import urllib.error
import urllib.request
from pathlib import Path
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives.asymmetric.utils import decode_dss_signature

KEY_ID = "S96HVY2BYT"
ISSUER = "aa5a3fcd-f139-4b1f-beb2-47fd125148d9"
TEAM_ID = "SRN7AW424S"
BUNDLE = "br.com.swingbrasilia.fun"
BUNDLE_NAME = "Swing Brasília"
KEY = Path("/home/richard/Documentos/play store/AuthKey_S96HVY2BYT.p8")


def b64(value: bytes) -> str:
    return base64.urlsafe_b64encode(value).rstrip(b"=").decode()


def token() -> str:
    header = b64(json.dumps({"alg": "ES256", "kid": KEY_ID, "typ": "JWT"}, separators=(",", ":")).encode())
    payload = b64(json.dumps({"iss": ISSUER, "iat": int(time.time()), "exp": int(time.time()) + 900, "aud": "appstoreconnect-v1"}, separators=(",", ":")).encode())
    unsigned = f"{header}.{payload}".encode()
    private_key = serialization.load_pem_private_key(KEY.read_bytes(), password=None)
    der = private_key.sign(unsigned, ec.ECDSA(hashes.SHA256()))
    r, s = decode_dss_signature(der)
    return f"{header}.{payload}.{b64(r.to_bytes(32, 'big') + s.to_bytes(32, 'big'))}"


def request(method, url, body=None):
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(url, data=data, headers={"Authorization": f"Bearer {token()}", "Content-Type": "application/json"}, method=method)
    try:
        with urllib.request.urlopen(req) as response:
            return json.loads(response.read())
    except urllib.error.HTTPError as error:
        return {"error": error.code, "detail": error.read().decode()}


def main():
    existing = request("GET", f"https://api.appstoreconnect.apple.com/v1/bundleIds?filter[identifier]={BUNDLE}")
    if existing.get("data"):
        resource_id = existing["data"][0]["id"]
        print(json.dumps({"bundleId": BUNDLE, "resourceId": resource_id, "status": "existing"}))
        return

    created = request("POST", "https://api.appstoreconnect.apple.com/v1/bundleIds", {
        "data": {
            "type": "bundleIds",
            "attributes": {"identifier": BUNDLE, "name": BUNDLE_NAME, "platform": "IOS"}
        }
    })
    if "error" in created:
        raise SystemExit(created)
    resource_id = created["data"]["id"]
    print(json.dumps({"bundleId": BUNDLE, "resourceId": resource_id, "status": "created"}))


if __name__ == "__main__":
    main()

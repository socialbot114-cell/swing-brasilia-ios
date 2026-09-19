#!/usr/bin/env python3
"""Cria um provisioning profile IOS_APP_STORE para um bundle e certificado conhecidos."""
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
KEY = Path("/home/richard/Documentos/play store/AuthKey_S96HVY2BYT.p8")

BUNDLE_ID = "br.com.swingbrasilia.fun"
BUNDLE_RESOURCE_ID = ""      # preencher com o resource ID retornado por create_bundle_id.py
CERTIFICATE_ID = ""          # preencher com o certificateId retornado por create_distribution_assets.py
PROFILE_NAME = "Swing Brasília App Store 2026"


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


def main():
    if not BUNDLE_RESOURCE_ID or not CERTIFICATE_ID:
        raise SystemExit("Preencha BUNDLE_RESOURCE_ID e CERTIFICATE_ID antes de rodar este script.")

    body = {
        "data": {
            "type": "profiles",
            "attributes": {"name": PROFILE_NAME, "profileType": "IOS_APP_STORE"},
            "relationships": {
                "bundleId": {"data": {"type": "bundleIds", "id": BUNDLE_RESOURCE_ID}},
                "certificates": {"data": [{"type": "certificates", "id": CERTIFICATE_ID}]},
            },
        }
    }
    data = json.dumps(body).encode()
    request = urllib.request.Request(
        "https://api.appstoreconnect.apple.com/v1/profiles",
        data=data,
        headers={"Authorization": f"Bearer {token()}", "Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(request) as response:
            print(response.read().decode())
    except urllib.error.HTTPError as error:
        print(error.read().decode())
        raise


if __name__ == "__main__":
    main()

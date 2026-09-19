#!/usr/bin/env python3
"""Cria certificado IOS_DISTRIBUTION e provisioning profile App Store para o Swing Brasília.

Salva os artefatos localmente (scripts/.swing-brasilia-distribution.*) e imprime
o JSON com certificateId, profileId e profileUUID para configurar os segredos do CI.
"""
import base64
import json
import subprocess
import time
import urllib.error
import urllib.request
from pathlib import Path
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives.asymmetric.utils import decode_dss_signature

ROOT = Path(__file__).parents[1]
KEY_ID = "S96HVY2BYT"
ISSUER = "aa5a3fcd-f139-4b1f-beb2-47fd125148d9"
API_KEY = Path("/home/richard/Documentos/play store/AuthKey_S96HVY2BYT.p8")
BUNDLE_ID = "br.com.swingbrasilia.fun"
PROFILE_NAME = "Swing Brasília App Store 2026"

PRIVATE_KEY = ROOT / "scripts/.swing-brasilia-distribution.key"
CSR_PATH = ROOT / "scripts/.swing-brasilia-distribution.csr"
CERT_PATH = ROOT / "scripts/.swing-brasilia-distribution.cer"
PROFILE_PATH = ROOT / "scripts/.swing-brasilia-distribution.mobileprovision"


def b64(value: bytes) -> str:
    return base64.urlsafe_b64encode(value).rstrip(b"=").decode()


def token() -> str:
    header = b64(json.dumps({"alg": "ES256", "kid": KEY_ID, "typ": "JWT"}, separators=(",", ":")).encode())
    payload = b64(json.dumps({"iss": ISSUER, "iat": int(time.time()), "exp": int(time.time()) + 900, "aud": "appstoreconnect-v1"}, separators=(",", ":")).encode())
    unsigned = f"{header}.{payload}".encode()
    private_key = serialization.load_pem_private_key(API_KEY.read_bytes(), password=None)
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
        raise SystemExit(error.read().decode())


def find_bundle_id():
    result = request("GET", f"https://api.appstoreconnect.apple.com/v1/bundleIds?filter[identifier]={BUNDLE_ID}")
    if not result.get("data"):
        raise SystemExit(f"Bundle ID {BUNDLE_ID} não encontrado. Rode create_bundle_id.py primeiro.")
    return result["data"][0]["id"]


def main():
    bundle_resource_id = find_bundle_id()

    subprocess.run(["openssl", "genrsa", "-out", str(PRIVATE_KEY), "2048"], check=True, capture_output=True)
    subprocess.run(
        ["openssl", "req", "-new", "-key", str(PRIVATE_KEY), "-outform", "DER", "-out", str(CSR_PATH), "-subj", "/CN=Swing Brasilia Distribution"],
        check=True, capture_output=True,
    )

    certificate_body = {
        "data": {
            "type": "certificates",
            "attributes": {
                "certificateType": "IOS_DISTRIBUTION",
                "csrContent": base64.b64encode(CSR_PATH.read_bytes()).decode(),
            },
        }
    }
    certificate = request("POST", "https://api.appstoreconnect.apple.com/v1/certificates", certificate_body)
    cert_data = certificate["data"]
    CERT_PATH.write_bytes(base64.b64decode(cert_data["attributes"]["certificateContent"]))

    profile_body = {
        "data": {
            "type": "profiles",
            "attributes": {"name": PROFILE_NAME, "profileType": "IOS_APP_STORE"},
            "relationships": {
                "bundleId": {"data": {"type": "bundleIds", "id": bundle_resource_id}},
                "certificates": {"data": [{"type": "certificates", "id": cert_data["id"]}]},
            },
        }
    }
    profile = request("POST", "https://api.appstoreconnect.apple.com/v1/profiles", profile_body)
    profile_data = profile["data"]
    PROFILE_PATH.write_bytes(base64.b64decode(profile_data["attributes"]["profileContent"]))

    print(json.dumps({
        "bundleId": BUNDLE_ID,
        "bundleResourceId": bundle_resource_id,
        "certificateId": cert_data["id"],
        "profileId": profile_data["id"],
        "profileName": PROFILE_NAME,
        "profileUUID": profile_data["attributes"]["uuid"],
    }))


if __name__ == "__main__":
    main()

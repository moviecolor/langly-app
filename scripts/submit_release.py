#!/usr/bin/env python3
"""Push Langly 1.2 (1) to App Store Connect for App Review.

Usage:
  python3 scripts/submit_release.py            # DRY RUN — reports what it WOULD do
  python3 scripts/submit_release.py --yes      # actually creates/submits

Requirements: ~/.appstoreconnect/keys/fastlane_api_key.json (ASC API key),
  cryptography (pip). Run from LANGLY_PROJECT root.
"""
import json, sys, time, urllib.request, base64

APP_ID = "6794917761"
BUILD_ID = "4b530a1d-abb6-4b0b-97e3-5783cb494538"  # Langly 1.2 (4) — live subscription product ID .monthly.2
VERSION = "1.2"
DRY = "--yes" not in sys.argv
cfg = json.load(open("/Users/mo-ry/.appstoreconnect/keys/fastlane_api_key.json"))

WHATSNEW_EN = ("Direction fixes for Portuguese learners:\n\n"
    "• PT→EN audio mode and word lists now show Portuguese first — learn the language you're practicing, the way it's actually used\n"
    "• Match Madness now puts your home language on the left column and the target language on the right — matches how your brain translates\n"
    "• Audio playback continues while the screen sleeps — lock your phone and keep listening without interruption\n")

WHATSNEW_PT = ("Correções de direção para quem aprende português:\n\n"
    "• O modo de áudio e as listas de palavras agora mostram português primeiro em PT→EN — aprenda o idioma que você pratica, do jeito que ele é realmente usado\n"
    "• O Jogo da Memória agora coloca a língua principal na coluna esquerda e o idioma-alvo na direita — combina com a forma como seu cérebro traduz\n"
    "• O áudio continua tocando enquanto a tela dorme — bloqueie o celular e continue ouvindo sem interrupções\n")

from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.serialization import load_pem_private_key
from cryptography.hazmat.primitives.asymmetric.utils import decode_dss_signature

def b64url(b): return base64.urlsafe_b64encode(b).rstrip(b"=").decode()
hdr = b64url(json.dumps({"alg":"ES256","kid":cfg["key_id"],"typ":"JWT"}).encode())
now = int(time.time())
claims = b64url(json.dumps({"iss":cfg["issuer_id"],"iat":now,"exp":now+1200,"aud":"appstoreconnect-v1"}).encode())
unsigned = f"{hdr}.{claims}"
key = load_pem_private_key(cfg["key"].encode(), password=None)
r, s = decode_dss_signature(key.sign(unsigned.encode(), ec.ECDSA(hashes.SHA256())))
TOKEN = f"{unsigned}.{b64url(r.to_bytes(32,'big') + s.to_bytes(32,'big'))}"

def api(path, method="GET", body=None):
    data = json.dumps(body).encode() if body else None
    req = urllib.request.Request("https://api.appstoreconnect.apple.com/v1"+path, data=data, method=method,
                                 headers={"Authorization":f"Bearer {TOKEN}","Content-Type":"application/json"})
    try:
        with urllib.request.urlopen(req) as r: return json.load(r) if r.status!=204 else {"status":204}
    except urllib.error.HTTPError as e:
        return {"ERROR": e.code, "body": e.read().decode()[:400]}

def plan(msg):
    print(("[DRY-RUN] " if DRY else "[DOING] ") + msg)

def existing_version():
    vs = api(f"/apps/{APP_ID}/appStoreVersions?limit=20").get("data", [])
    return next((v for v in vs if v["attributes"].get("versionString") == VERSION), None)

def main():
    print("Mode:", "DRY-RUN (pass --yes to actually submit)" if DRY else "EXECUTE")
    ver = existing_version()
    if ver:
        plan(f"appStoreVersion {VERSION} EXISTS ({ver['id']}), state={ver['attributes'].get('appStoreState')}")
    else:
        plan(f"CREATE appStoreVersion {VERSION} on app {APP_ID}")
        if not DRY:
            ver = api("/appStoreVersions", "POST", {"data":{"type":"appStoreVersions",
                "attributes":{"platform":"IOS","versionString":VERSION},
                "relationships":{"app":{"data":{"type":"apps","id":APP_ID}}}}}).get("data")
            if not ver: sys.exit("Failed to create appStoreVersion")
    vid = ver["id"] if ver else "NEW_ID"

    plan(f"ATTACH build {BUILD_ID} to version {vid}")
    if not DRY:
        api(f"/appStoreVersions/{vid}/relationships/build", "PATCH",
            {"data":{"type":"builds","id":BUILD_ID}})

    locs = api(f"/appStoreVersions/{vid}/appStoreVersionLocalizations").get("data", [])
    for locale, text in (("en-US", WHATSNEW_EN), ("pt-BR", WHATSNEW_PT)):
        found = next((l for l in locs if l["attributes"].get("locale")==locale), None)
        if found:
            plan(f"PATCH whatsNew ({locale}) on loc {found['id']}")
            if not DRY:
                api(f"/appStoreVersionLocalizations/{found['id']}", "PATCH",
                    {"data":{"type":"appStoreVersionLocalizations","id":found["id"],
                             "attributes":{"whatsNew":text}}})
        else:
            plan(f"CREATE localization ({locale})")
            if not DRY:
                api("/appStoreVersionLocalizations", "POST",
                    {"data":{"type":"appStoreVersionLocalizations",
                             "attributes":{"locale":locale,"whatsNew":text},
                             "relationships":{"appStoreVersion":{"data":{"type":"appStoreVersions","id":vid}}}}})

    rd = api(f"/appStoreVersions/{vid}/appStoreReviewDetail")
    if rd.get("data"):
        plan(f"appStoreReviewDetail EXISTS ({rd['data']['id']})")
    else:
        # copy values from the 1.1 version if present
        old = api("/apps/6794917761/appStoreVersions?limit=20").get("data", [])
        src = next((v for v in old if v["attributes"].get("versionString")=="1.1"), None)
        plan("appStoreReviewDetail MISSING -> will create (copying values from 1.1)")
        if not DRY and src:
            src_rd = api(f"/appStoreVersions/{src['id']}/appStoreReviewDetail")
            attrs = src_rd.get("data",{}).get("attributes",{})
            api("/appStoreReviewDetails", "POST",
                {"data":{"type":"appStoreReviewDetails","attributes":attrs,
                         "relationships":{"appStoreVersion":{"data":{"type":"appStoreVersions","id":vid}}}}})

    plan(f"SUBMIT for review: version {vid}")
    if not DRY:
        res = api("/appStoreVersionSubmissions", "POST",
            {"data":{"type":"appStoreVersionSubmissions",
                     "relationships":{"appStoreVersion":{"data":{"type":"appStoreVersions","id":vid}}}}})
        print("SUBMIT response:", json.dumps(res)[:400])

    print("\nDONE." + ("" if DRY else " Submitted for App Review."))

if __name__ == "__main__":
    main()
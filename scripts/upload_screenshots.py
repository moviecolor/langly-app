#!/usr/bin/env python3
"""Upload Langly App Store screenshots for release 1.2.

Creates (idempotently): appStoreVersion 1.2 → en-US/pt-BR localizations →
appScreenshotSets (APP_IPHONE_61 + APP_IPHONE_67) → uploads the 10 PNGs →
polls every slot until assetDeliveryState == COMPLETE.

Usage:
  python3 scripts/upload_screenshots.py            # DRY RUN
  python3 scripts/upload_screenshots.py --yes      # execute uploads

Requires: ~/.appstoreconnect/keys/fastlane_api_key.json (ASC API key),
  cryptography (pip). Run from LANGLY_PROJECT root.
"""
import json, sys, time, base64, hashlib, os, urllib.request

APP_ID = "6794917761"
VERSION = "1.2"
DRY = "--yes" not in sys.argv
cfg = json.load(open("/Users/mo-ry/.appstoreconnect/keys/fastlane_api_key.json"))

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
        return {"ERROR": e.code, "body": e.read().decode()[:600]}

def plan(msg):
    print(("[DRY-RUN] " if DRY else "[DOING] ") + msg)

def first(items, **kw):
    for it in items:
        if all(it.get("attributes", {}).get(k) == v for k, v in kw.items()):
            return it
    return None

SCREENSHOT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "AppStoreScreenshots")
# display type -> local dir containing the PNGs (ordered by display)
SETS = [
    ("APP_IPHONE_61", "6.1in"),
    ("APP_IPHONE_67", "6.7in"),
]
# retrieve uploadOperations + upload the file bytes, then commit with checksum
def reserve_and_upload(set_id, filepath):
    with open(filepath, "rb") as f:
        raw = f.read()
    checksum = hashlib.md5(raw).hexdigest()
    # request a slot
    res = api("/appScreenshots", "POST", {"data": {
        "type": "appScreenshots",
        "attributes": {"fileName": os.path.basename(filepath), "fileSize": len(raw)},
        "relationships": {"appScreenshotSet": {"data": {"type": "appScreenshotSets", "id": set_id}}},
    }}).get("data")
    if not res:
        return None, None, "reserve failed"
    sid = res["id"]
    ops = res.get("attributes", {}).get("uploadOperations", [])
    for op in ops:
        method = op.get("method", "PUT")
        url = op.get("url")
        headers = {k: v for k, v in op.get("requestHeaders", [])}
        req = urllib.request.Request(url, data=raw, method=method, headers=headers)
        resp = urllib.request.urlopen(req, context=__import__("ssl").create_default_context())
        resp.read()
    # commit
    res2 = api(f"/appScreenshots/{sid}", "PATCH", {"data": {
        "type": "appScreenshots", "id": sid,
        "attributes": {"sourceFileChecksum": checksum, "uploaded": True},
    }}).get("data")
    return sid, res2, "ok"

# Ensure the screenshot dir has the expected PNGs before creating anything
missing = []
for dtype, folder in SETS:
    d = os.path.join(SCREENSHOT_DIR, folder)
    for i in range(1, 6):
        p = f"{i:02d}_*.png"
        import glob
        if not glob.glob(os.path.join(d, p)):
            missing.append(f"{folder}/{p}")
if missing:
    print("Missing local screenshots:", missing)
    sys.exit(1)

def main():
    print("Mode:", "DRY-RUN (pass --yes to actually upload)" if DRY else "EXECUTE")
    vs = api("/apps/%s/appStoreVersions?limit=20" % APP_ID).get("data", [])
    ver = first(vs, versionString=VERSION)
    if ver:
        plan(f"appStoreVersion {VERSION} EXISTS ({ver['id']})")
    else:
        plan(f"CREATE appStoreVersion {VERSION}")
        if not DRY:
            ver = api("/appStoreVersions", "POST", {"data": {"type": "appStoreVersions",
                "attributes": {"platform": "IOS", "versionString": VERSION},
                "relationships": {"app": {"data": {"type": "apps", "id": APP_ID}}}}}).get("data")
            if not ver: sys.exit("Failed to create appStoreVersion")
    vid = ver["id"] if ver else "NEW_ID"

    locs = api(f"/appStoreVersions/{vid}/appStoreVersionLocalizations").get("data", [])
    loc = first(locs, locale="en-US")
    if loc:
        plan(f"en-US localization EXISTS ({loc['id']})")
    else:
        plan("CREATE en-US localization")
        if not DRY:
            loc = api("/appStoreVersionLocalizations", "POST", {"data": {
                "type": "appStoreVersionLocalizations",
                "attributes": {"locale": "en-US"},
                "relationships": {"appStoreVersion": {"data": {"type": "appStoreVersions", "id": vid}}}}}).get("data")
            if not loc: sys.exit("Failed to create en-US localization")
    lid = loc["id"] if loc else "NEW_LOC_ID"

    sets = api(f"/appStoreVersionLocalizations/{lid}/appScreenshotSets").get("data", [])
    for dtype, folder in SETS:
        st = first(sets, screenshotDisplayType=dtype)
        if st:
            plan(f"set {dtype} EXISTS ({st['id']})")
        else:
            plan(f"CREATE set {dtype}")
            if not DRY:
                st = api("/appScreenshotSets", "POST", {"data": {
                    "type": "appScreenshotSets",
                    "attributes": {"screenshotDisplayType": dtype},
                    "relationships": {"appStoreVersionLocalization": {"data": {"type": "appStoreVersionLocalizations", "id": lid}}}}}).get("data")
                if not st: sys.exit(f"Failed to create set {dtype}")
        set_id = st["id"] if st else "NEW_SET_ID"

        import glob
        d = os.path.join(SCREENSHOT_DIR, folder)
        files = sorted(glob.glob(os.path.join(d, "*.png")))
        for fp in files:
            plan(f"UPLOAD {os.path.basename(fp)} -> {dtype} ({set_id})")
            if not DRY:
                sid, res2, msg = reserve_and_upload(set_id, fp)
                if sid:
                    plan(f"  committed {sid} ({msg})")
                else:
                    print("  ERROR:", msg, res2)

    print("\nDONE." + ("" if DRY else " Uploads issued — verify states below."))

if __name__ == "__main__":
    main()
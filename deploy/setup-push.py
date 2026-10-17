"""Run on VPS. Generates VAPID once and never prints key material."""
import json
import os
import subprocess
from pathlib import Path
path = Path('/home/ducnp/eled/.env')
content = path.read_text()
if 'VAPID_PRIVATE_KEY=' in content and 'VAPID_PUBLIC_KEY=' in content:
    print('Preserving existing Web Push keys')
    raise SystemExit(0)
if 'VAPID_PRIVATE_KEY=' in content or 'VAPID_PUBLIC_KEY=' in content:
    raise SystemExit('Incomplete Web Push keys; preserving file for manual repair')
script = """const {generateKeyPairSync}=require('node:crypto');
const {privateKey}=generateKeyPairSync('ec',{namedCurve:'prime256v1'});
const k=privateKey.export({format:'jwk'});
console.log(JSON.stringify({publicKey:Buffer.concat([Buffer.from([4]),Buffer.from(k.x,'base64url'),Buffer.from(k.y,'base64url')]).toString('base64url'),privateKey:k.d}));"""
result = subprocess.run(['docker','exec','-i','eled-api-1','node','-'],input=script,text=True,capture_output=True,check=True)
keys = json.loads(result.stdout)
os.chmod(path, 0o600)
with path.open('a') as file:
    file.write('\nVAPID_PUBLIC_KEY=' + keys['publicKey'] + '\nVAPID_PRIVATE_KEY=' + keys['privateKey'] + '\nVAPID_SUBJECT=https://eled.vnlab.id.vn\n')
print('Created persistent Web Push keys in private server environment file')

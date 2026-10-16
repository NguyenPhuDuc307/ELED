"""Run on the VPS with python3; never prints a password or connection string."""
import os
import secrets
import subprocess
from pathlib import Path
base = Path('/home/ducnp/eled')
base.mkdir(exist_ok=True)
env = base / '.env'
if env.exists():
    print('Database configuration already exists; preserving it')
    raise SystemExit(0)
password = secrets.token_urlsafe(36)
sql = fr"""SELECT 'CREATE ROLE eled LOGIN PASSWORD ''{password}''' WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname='eled')\gexec
SELECT 'CREATE DATABASE eled OWNER eled' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname='eled')\gexec
"""
result = subprocess.run(['docker','exec','-i','server-db-1','sh','-c','exec psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d postgres'],input=sql,text=True,capture_output=True)
if result.returncode:
    print('Database setup failed; no environment file written')
    raise SystemExit(1)
fd = os.open(env, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
with os.fdopen(fd,'w') as file:
    file.write(f'DATABASE_URL=postgresql://eled:{password}@db:5432/eled\n')
print('Created dedicated ELED database, role and private environment file')

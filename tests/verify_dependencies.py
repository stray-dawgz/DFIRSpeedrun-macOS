"""Audit transitive artifact definitions for Windows-only query dependencies.

Usage: python tests/verify_dependencies.py /path/to/velociraptor
This inspects definitions only; it does not acquire endpoint evidence.
"""
from pathlib import Path
import re
import subprocess
import sys

root = Path(__file__).resolve().parents[1]
policy = (root / 'artifacts/DFIRSpeedrun.MacOS.Triage.yaml').read_text()
pending = [policy]
seen = set()
while pending:
    definition = pending.pop()
    assert not re.search(r'\bwmi\s*\(', definition), 'Windows WMI dependency in collection graph'
    for name in re.findall(r'Artifact\.([A-Za-z0-9_.]+)\s*\(', definition):
        assert not name.startswith('Windows.'), name
        if name in seen:
            continue
        result = subprocess.run([sys.argv[1], 'artifacts', 'show', name], capture_output=True, text=True)
        assert result.returncode == 0 and 'name:' in result.stdout, (name, result.stdout, result.stderr)
        seen.add(name)
        pending.append(result.stdout)
assert 'Artifact.Generic.Client.Info(' not in policy
assert 'query: SELECT * FROM info()' in policy
assert 'query: SELECT * FROM interfaces()' in policy
print('PASS: host uses info()/interfaces(); inspected ' + str(len(seen)) + ' transitive artifact definitions; no WMI or Windows artifact calls.')

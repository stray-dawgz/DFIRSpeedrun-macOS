"""Regression: parse the exact shipped Commands declaration without running it.

Usage: python tests/verify_commands.py /path/to/velociraptor
Uses only the Python standard library. Does not acquire endpoint evidence.
"""
import json
from pathlib import Path
import subprocess
import sys
import tempfile

root = Path(__file__).resolve().parents[1]
text = (root / 'artifacts/DFIRSpeedrun.MacOS.Triage.yaml').read_text()
block = text.split('  - name: Commands\n    query: |\n', 1)[1]
query = '\n'.join(line[6:] for line in block.splitlines())
declaration = query[:query.index('SELECT * FROM foreach')]
with tempfile.TemporaryDirectory() as folder:
    path = Path(folder) / 'commands.vql'
    path.write_text(declaration + '\nSELECT Commands AS Commands FROM scope()\n')
    result = subprocess.run([sys.argv[1], 'query', '--from_files', str(path), '--format', 'json'], capture_output=True, text=True)
    assert result.returncode == 0 and 'error:' not in result.stdout + result.stderr, (result.stdout, result.stderr)
    rows = json.loads(result.stdout[result.stdout.index('[\n'):])
    commands = rows[0]['Commands']
    assert len(commands) == 26
    assert len({c['Label'] for c in commands}) == 26
    assert all(c['Argv'] and c['Argv'][0].startswith('/') for c in commands)
    path.write_text(query.replace('foreach(row=Commands,', 'foreach(row=[],', 1))
    result = subprocess.run([sys.argv[1], 'query', '--from_files', str(path), '--format', 'json'], capture_output=True, text=True)
    assert result.returncode == 0 and 'error:' not in result.stdout + result.stderr, (result.stdout, result.stderr)
print('PASS: exact shipped declaration and full Commands query compile; 26 commands enumerated without executing them.')

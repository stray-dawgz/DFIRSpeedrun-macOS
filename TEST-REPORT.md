# DFIRSpeedrun macOS v0.1.0-rc2 test report

The rc1 native run failed before acquisition because its Commands source used
an invalid VQL direct array assignment. The earlier verifier and substituted
command fixture did not catch the shipped declaration. This was a tool defect.

rc2 uses a JSON command declaration parsed by parse_json_array. The exact rc1
parser error was reproduced on the pinned Windows engine. The corrected shipped
declaration evaluates successfully, preserving all 26 labels and argument vectors.
The full shipped Commands query also compiles with empty execution input.

Repeated checks passed: artifact verification; raw upload byte/hash accuracy;
oversize skipping; document exclusion; context files in ZIP; command stdout,
stderr, nonzero return code and continuation; Bash syntax; nine mocked launcher
scenarios including TERM interruption and clearing inherited configuration.
Both upstream macOS binary hashes are unchanged. Release packaging validates
every manifest hash, executable modes and Mach-O architecture headers.

Native rc2 collection, Full Disk Access, Gatekeeper and evidence coverage remain
unvalidated. Use as a supplemental collector until a native run is reviewed.
Extract rc2 into a new folder rather than overwriting prior evidence.

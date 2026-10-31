# DFIRSpeedrun macOS release-candidate test report

Tested 2026-10-31 on Windows. Package: `DFIRSpeedrun-macOS-0.1.0-rc1.tar.gz`.

**Result:** all performed checks passed. No collector/package changes were needed
in this test pass. The original delivered archive remains unchanged. No native
macOS execution occurred, so this result is not approval for sole-collector use
on an assessment.

Archive SHA-256:
`2e48c9c44efd132a9b709d90706d4eb95b2438a02f6ac2e6774690495b566c6e`

## Real checks on available tools and controlled files

| Check | Result |
| --- | --- |
| Original archive SHA-256 matches delivered sidecar | PASS |
| Every archived file matches its manifest and unpacked source | PASS |
| Manifest covers all package files except itself | PASS |
| Archive paths/membership have no duplicates, traversal paths or links | PASS |
| Executable permissions and LF text endings | PASS |
| Both macOS binaries match pinned upstream release hashes | PASS |
| Mach-O headers identify the expected Intel and ARM architectures | PASS |
| Bash syntax | PASS |
| Launcher refuses a real non-macOS invocation | PASS |
| Custom artifact passes pinned Velociraptor artifact verification | PASS |
| Controlled raw files uploaded with expected bytes and SHA-256 | PASS |
| Oversized fixture listed as skipped and absent from uploads | PASS |
| Document outside the fixture allowlist excluded | PASS |
| Preflight/run-start context preserved byte-for-byte in ZIP | PASS |
| ZIP integrity | PASS |
| Real child command stdout/stderr and exit code 7 captured | PASS |
| Next child command still runs after nonzero exit | PASS |

The VQL execution tests used the pinned Windows Velociraptor engine, controlled
fixtures and controlled commands. Raw glob enumeration was rooted at the fixture
directory to accommodate the Windows sandbox. These tests establish query and
container behavior; they do not test macOS accessors or macOS command behavior.

## Launcher tests with substituted commands

All nine cases passed: Apple silicon selection; Intel selection; Rosetta
selection; collector nonzero exit; missing output; corrupt ZIP; package hash
failure; missing elevation; interruption by TERM.

Successful runs received a final ZIP name and review-required status. Tested
collection failures/interruption retained identifiable partial output instead.
Test directories included spaces. The mocked collector confirmed inherited
`VELOCIRAPTOR_CONFIG`, `VELOCIRAPTOR_API_CONFIG` and
`VELOCIRAPTOR_LITERAL_CONFIG` variables were cleared.

These are control-flow tests on a temporary launcher copy. They do not test
macOS signing, Gatekeeper, native `unzip`/`shasum`, FDA, or macOS signal delivery.
Disk-full behavior, forced KILL, actual collection deadlines and native process
cleanup have not been exercised.

## Still required on a Mac

- Verify native launch/signing/Gatekeeper behavior on the assessment's OS and CPU.
- Run with and without Full Disk Access and inspect collection gaps.
- Seed known evidence, acquire it and check actual results and raw databases.
- Review native command return codes and logs, including Unified Log coverage.
- Verify evidence hashes after transfer and import the ZIP into the analysis tool.

**Assessment guidance:** suitable to take to a lab Mac for validation now. Use as
a supplemental collector until a native acquisition and evidence review pass.
Keep the established acquisition method available. See the packaged
`VALIDATION.md` for the fuller native test checklist.

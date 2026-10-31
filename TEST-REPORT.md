# DFIRSpeedrun macOS v0.1.0-rc3 test report

rc3 removes the Generic.Client.Info dependency responsible for the native rc2
startup failure `Plugin wmi not found`. Host and interface sources now call the
platform-neutral info() and interfaces() plugins directly.

All seven remaining referenced/transitive artifact definitions were inspected:
no WMI queries or Windows artifact calls remain. Both exact replacement sources
produced expected results in the pinned Windows engine's controlled collection.
The shipped Commands declaration and full query passed regression checks.

Repeated checks passed: artifact verification, raw upload byte/hash accuracy,
oversize skipping, allowlist exclusion, preflight context, ZIP integrity, command
stdout/stderr/return codes/continuation, Bash syntax, and nine mocked launcher
scenarios. Release packaging checks hashes, file modes and architecture headers.

The native macOS rc2 failure establishes that Windows tests were insufficient
to establish macOS compatibility. Native rc3 compilation, collection coverage,
Full Disk Access and Gatekeeper still need verification. Extract rc3 into a NEW
folder and preserve previous logs/partial evidence. This is a release candidate.

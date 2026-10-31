# Reproducible package inputs

Pinned engine: Velociraptor 0.77.2, matching the Windows baseline. This pin is a
compatibility choice, not a claim that it is the latest or audited release.

Release metadata: https://api.github.com/repos/Velocidex/velociraptor/releases/tags/v0.77.2

| File | SHA-256 from GitHub release asset metadata |
| --- | --- |
| velociraptor-v0.77.2-darwin-amd64 | 900efb29154939e6f594446096975439fc19c59fd74f5433d67bc15cacb4cd99 |
| velociraptor-v0.77.2-darwin-arm64 | 3ec2df0c19726b92e27c51ec4b6239aee3e4e40425de39781859eb200987070e |

Download from:

- https://github.com/Velocidex/velociraptor/releases/download/v0.77.2/velociraptor-v0.77.2-darwin-amd64
- https://github.com/Velocidex/velociraptor/releases/download/v0.77.2/velociraptor-v0.77.2-darwin-arm64

The hashes establish correspondence with GitHub release metadata; detached
upstream signatures and macOS code-signing validity were not independently
validated on this Windows build host. Check signatures on your validation Macs.

Keep the upstream binaries byte-for-byte intact in `bin/`. The collection policy
is fully specified by `artifacts/DFIRSpeedrun.MacOS.Triage.yaml`; there are no
external artifact packs or tools downloaded during collection. Review the
launcher and artifact before deploying with administrative privileges.

After changing any source, regenerate `SHA256SUMS` over every regular package
file except `SHA256SUMS` itself. Normalize text files to LF. Set executable mode
0755 on the launcher and both binaries and 0644 on other files when producing the
tar.gz archive. On a Mac, one way to rebuild the manifest is:

```bash
cd DFIRSpeedrun-macOS
find . -type f ! -name SHA256SUMS -print | LC_ALL=C sort | while IFS= read -r f; do
  shasum -a 256 "$f"
done > SHA256SUMS
chmod 755 Start-DFIRSpeedrun.command bin/velociraptor-*
cd ..
tar -czf DFIRSpeedrun-macOS-0.1.0-rc2.tar.gz DFIRSpeedrun-macOS
shasum -a 256 DFIRSpeedrun-macOS-0.1.0-rc2.tar.gz
```

Do not rebuild from a directory containing case outputs or temporary workspaces.
Hash and approve the final archive through your normal distribution process.

Upstream explains why macOS collectors should avoid modifying signed binaries:
https://docs.velociraptor.app/docs/deployment/offline_collections/

This package instead invokes the documented local `artifacts collect` CLI:
https://docs.velociraptor.app/docs/cli/commands/artifacts/

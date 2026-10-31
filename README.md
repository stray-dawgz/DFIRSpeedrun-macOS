# DFIRSpeedrun for macOS — 0.1.0-rc3

An unattended, offline endpoint triage collector based on Velociraptor 0.77.2,
matching the operating model of DFIRSpeedrun Windows v0.2.0. Includes native Intel
and Apple silicon binaries; needs no Homebrew, Python, server, or runtime download.

**Release candidate: configuration and packaging verified on Windows. Actual
collection, signing/Gatekeeper behavior, Full Disk Access, and command behavior
still require macOS validation. Do not treat this as a validated field release.**

## Run on a Mac

1. Verify the archive's published SHA-256, then extract the `.tar.gz` on a local,
   writable APFS volume. The archive preserves executable permissions.
2. In Terminal, enter the extracted `DFIRSpeedrun-macOS` folder. Verify its files:

   ```bash
   shasum -a 256 -c SHA256SUMS
   ```

3. Preauthorize access using your organization's macOS deployment process or
   System Settings > Privacy & Security > Full Disk Access for the application
   launching the collector (typically Terminal). Restart that application if
   required. Exact access depends on macOS version and deployment identity;
   `sudo` alone is not evidence of Full Disk Access. Do not disable SIP or bypass
   Gatekeeper as part of this workflow. Check launch/signing issues with your
   deployment administrator.
4. Run:

   ```bash
   sudo ./Start-DFIRSpeedrun.command
   ```

   `sudo` may request the administrator's password. The collector itself asks no
   questions. It selects the native binary, including when Terminal uses Rosetta,
   verifies package hashes, records read probes, and runs the collection.

5. Retrieve all files sharing the new `DFIRSpeedrun-<host>-<UTC>-<id>` basename:

   - `.zip`: standard Velociraptor evidence container with JSONL source results,
     selected raw artifacts, upload hashes, preflight, and collection logs.
   - `.log`: external diagnostics.
   - `.preflight.txt`: OS, identity, disk space, SIP status, protected-file probes.
   - `.status.txt`: start/end, collector exit code, packaging result.
   - `.sha256`: hashes of the four preceding files.

   Failed/interrupted runs keep `.partial.zip` when available. The private
   `.DFIRSpeedrun-*` workspace remains beside the launcher and may contain
   sensitive temporary files; retain it for failed-run diagnosis and remove it
   under your evidence-retention procedure after acquisition review.

No service is installed, no settings are changed, and no uploads are configured.
The bundled binaries are upstream binaries, not repacked executables. The launcher
and custom artifact have not been code-signed or notarized by your organization.

## Coverage

| Area | Collection |
| --- | --- |
| Identity and host | Host details, all local accounts, local admins, logged-in users, recent logins, OS, uptime |
| Live state | Processes and image hashes where readable, sockets, interfaces, routes, DNS and proxy configuration |
| Persistence | LaunchAgent/Daemon plists, disabled-job plists, crontabs, background/login-item databases, launchd and background-item command output |
| Software and security | Application inventory, package receipts, installation history, configuration profiles, extensions, FileVault and firewall state |
| Execution and downloads | Quarantine event metadata, shell histories, TCC records |
| Browsers | Chrome history results; raw Safari, Chrome, Edge and Firefox history databases, including matching SQLite sidecars |
| Logs | Current system/install logs; a filtered 24-hour Unified Log query for sudo, sshd, authd, syspolicyd, tccd and XProtectService |
| Storage | Mounted volumes, disk/APFS inventories; no volume image or file-system journal sweep |

Full raw Unified Log archives, FSEvents, memory, documents, executable samples,
browser cookies/passwords, keychains, private keys, and local password-hash plists
are not targeted. Persistence files and histories can contain executable text or
secrets; they remain untrusted evidence even without standalone malware samples.

## Review collection quality

Exit `0` means ZIP creation and ZIP integrity testing completed, **possibly with
partial collection errors**. Exit `1` means failure; exit `5` means elevation was
missing; exit `130` means the launcher caught an interruption.

`PACKAGED_REVIEW_REQUIRED` deliberately does not certify full coverage. Review:

- protected-file probes; `NOT_VISIBLE_OR_ABSENT` does not distinguish missing
  data from macOS privacy controls;
- ZIP logs and each command's stderr/return code (some commands do not exist on
  older releases, and inactive subsystems can return nonzero normally);
- `RawPathCoverage`: no matches can mean missing OR inaccessible data;
- `RawArtifacts`: skipped-size decisions and missing/failed Upload results.

Raw files above 128 MiB and symbolic-link files are recorded but skipped; raw
collection does not recurse through symbolic-link directories. Collection has a 30-minute
deadline and a five-minute no-progress timeout. No total ZIP-size limit is set;
prepare sufficient free space and review timeouts. Command output uses 1 MiB
streaming buffers; a large result can occupy multiple rows. There is no global
consistency snapshot: live SQLite files/WALs are collected sequentially and may
change mid-run. Safari, Firefox and Edge history parsing is examiner work in this
version. Chrome's upstream parser is deprecated but pinned with the engine.

Readability probes are a limited observation, not an authoritative FDA/TCC check.
Success on one path does not establish access to all users or protected stores.
Off-host telemetry is needed to corroborate evidence from a compromised system.

## Evidence handling

Record authorization, case/examiner identity, target clock offset, start/end times,
source host, tool hash, collection gaps and transfer details separately. Avoid
rebooting before live acquisition. Live collection changes host state.

The outputs are **not encrypted**. Use approved encrypted storage and transfer.
Verify the `.sha256` after transfer and analyze copies in an isolated forensic
environment. Do not extract or open raw artifacts on an everyday workstation.
Keep the original package separate from case outputs before reusing it.

See `VALIDATION.md`, `BUILDING.md`, and `THIRD_PARTY_NOTICES.md`.

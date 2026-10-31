# Validation — 0.1.0-rc2

Build date: 2026-10-31. Build/test host: Windows. No macOS host was available.

## Completed checks

- Both upstream macOS binaries match the SHA-256 digests reported by the pinned
  GitHub release API.
- Launcher passes Git Bash `bash -n` and refuses a real non-macOS invocation.
- Velociraptor 0.77.2 `artifacts verify --issues_only` accepts the custom artifact.
- The pinned Windows engine ran the raw-upload, run-context and path-coverage
  queries against controlled fixtures. Only the raw glob root was adapted to a
  local fixture root because sandboxed drive-root enumeration was unavailable.
  The test verified ZIP integrity, exact uploaded bytes and SHA-256, skipping an
  oversized file, and exclusion of a document outside the allowlist. This tests
  VQL behavior, not macOS filesystem/privacy behavior.
- Launcher control flow passed eight tests with macOS commands and collector
  substituted in a temporary copy: ARM selection, Intel selection, Rosetta
  selection, collector nonzero exit, missing output, invalid ZIP, hash failure,
  and missing elevation. Paths contained spaces. These were mocks, not native
  collection/signing tests.
- Release archive membership, file modes and every manifest hash were checked
  after packaging.

## Required before field release

Run on disposable, authorized test Macs for both Intel and Apple silicon, with
the oldest and newest macOS versions your organization intends to support.
Record the exact OS/build, architecture, Terminal/launcher identity, package
hash, signing assessment, collection runtime/size, errors and expected evidence.

1. Check the bundled engine's signing validity with `codesign --verify --verbose=2`
   on each binary, and assess launch behavior with your deployment policy. The
   upstream bytes were preserved; this does not certify Gatekeeper acceptance.
2. Run with root but without Full Disk Access. Verify that collection continues
   and records inaccessible protected paths without certifying full coverage.
3. Grant access through the supported deployment process, restart the launching
   application as appropriate, and repeat. Compare results for multiple users;
   do not use a single successful probe as proof of unrestricted access.
4. Seed known browser history/download records, quarantine events, shell history,
   LaunchAgent/Daemon plists, a background login item and a crontab. Check that
   expected records or raw databases/configurations appear. Do not execute the
   seeded persistence. Check absent sources versus access failures explicitly.
5. Validate process image hashes, live sockets, local admins, application and
   extension inventories, and selected Unified Log events against ground truth.
6. Check every command's return code. Confirm the filtered Unified Log query
   completes on each OS and that expected records are present. Version-specific
   command failures must remain visible.
7. Test interruption, full disk/unwritable output, engine timeout, repeated runs,
   a missing/tampered package file, and ZIP corruption. Ensure incomplete evidence
   stays identifiable and no failed run receives a normal final ZIP name.
8. Verify ZIP and sidecar hashes after transfer. Test import into an isolated
   Velociraptor analysis environment and confirm expected JSONL results/uploads.

Do not remove the release-candidate label until these native checks pass. This
triage package does not replace imaging, memory acquisition, EDR or examiner review.

## rc2 regression fix

The first native rc1 attempt failed before collection while parsing the Commands
source: `1:17: unexpected token "["`. The direct array assignment was invalid
for the pinned VQL parser. rc2 uses parse_json_array for the command declaration.
The failure was reproduced on the pinned Windows engine; the fixed declaration
was evaluated and all 26 command labels and argument vectors matched. The exact
Commands query also compiled with an empty execution input. Fixture collection
and all nine launcher scenarios passed again. Native rc2 collection still needs
validation. Earlier fixture tests replaced the declaration and missed this bug.

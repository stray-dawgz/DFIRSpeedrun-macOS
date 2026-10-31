#!/bin/bash
# DFIRSpeedrun macOS 0.1.0-rc3. No runtime downloads or enrollment.
set -u
set -o pipefail
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
export LC_ALL=C
# Do not inherit enrollment/server configuration from an operator's environment.
unset VELOCIRAPTOR_CONFIG VELOCIRAPTOR_API_CONFIG VELOCIRAPTOR_LITERAL_CONFIG
umask 077

fail() { printf '%s\n' "$*" >&2; exit 1; }
[[ $# -eq 0 ]] || fail 'This launcher accepts no arguments.'
[[ "$(/usr/bin/uname -s)" == Darwin ]] || fail 'This collector requires macOS.'
[[ $EUID -eq 0 ]] || { printf '%s\n' 'Run from Terminal: sudo ./Start-DFIRSpeedrun.command' >&2; exit 5; }
[[ ! -L "$0" ]] || fail 'Run the original launcher, not a symbolic link.'
BASE=$(cd -P -- "$(/usr/bin/dirname -- "$0")" && pwd) || exit 1
cd "$BASE" || exit 1
case "$(/usr/bin/uname -m)" in
  arm64) ARCH=arm64 ;;
  x86_64) ARCH=amd64 ;;
  *) fail 'Unsupported processor architecture.' ;;
esac
# Detect an Intel Terminal running under Rosetta on Apple silicon.
if [[ "$(/usr/sbin/sysctl -in sysctl.proc_translated 2>/dev/null)" == 1 ]]; then ARCH=arm64; fi
BIN="$BASE/bin/velociraptor-v0.77.2-darwin-$ARCH"
[[ -f "$BIN" && ! -L "$BIN" ]] || fail 'Missing or symlinked Velociraptor binary.'
[[ -f "$BASE/SHA256SUMS" && ! -L "$BASE/SHA256SUMS" ]] || fail 'Missing release manifest.'
# Check the entire package before running the upstream binary as root.
/usr/bin/shasum -a 256 -c SHA256SUMS || fail 'Package hash verification failed.'
[[ -x "$BIN" ]] || fail 'Executable bit missing. Re-extract the supplied tar.gz archive.'

HOST=$(/bin/hostname -s 2>/dev/null | /usr/bin/tr -cd 'A-Za-z0-9._-')
[[ -n "$HOST" ]] || HOST=unknown
STAMP=$(/bin/date -u +%Y%m%dT%H%M%SZ)
RUN=$(/usr/bin/mktemp -d "$BASE/.DFIRSpeedrun-$HOST-$STAMP.XXXXXX") || fail 'Package directory must be writable.'
ID=${RUN##*.}
STEM="$BASE/DFIRSpeedrun-$HOST-$STAMP-$ID"
LOG="$STEM.log"
STATUS="$STEM.status.txt"
PREFLIGHT="$STEM.preflight.txt"
PARTIAL="$STEM.partial.zip"
FINAL="$STEM.zip"
CHILD=
finish_interrupted() {
  trap - INT TERM HUP
  if [[ -n "$CHILD" ]]; then
    /bin/kill -TERM "$CHILD" 2>/dev/null || true
    wait "$CHILD" 2>/dev/null || true
  fi
  printf 'state=INTERRUPTED\nended_utc=%s\n' "$(/bin/date -u +%FT%TZ)" >> "$STATUS"
  printf '%s\n' "Interrupted. Preserve $STEM.* and $RUN" >&2
  exit 130
}
trap finish_interrupted INT TERM HUP
printf 'version=0.1.0-rc3\nstate=RUNNING\nstarted_utc=%s\narchitecture=%s\n' "$(/bin/date -u +%FT%TZ)" "$ARCH" > "$STATUS" || exit 1
{
  printf 'DFIRSpeedrun macOS 0.1.0-rc3\nUTC: '; /bin/date -u +%FT%TZ
  /usr/bin/sw_vers
  /usr/bin/uname -a
  /usr/bin/id
  printf '\nDisk space (KiB):\n'; /bin/df -k "$BASE"
  printf '\nSIP status (no settings changed):\n'; /usr/bin/csrutil status
  printf '\nRead probes, not a definitive Full Disk Access verdict.\n'
  printf 'A missing or unreadable path does not establish why access failed.\n'
  for P in '/Library/Application Support/com.apple.TCC/TCC.db' \
    /Users/*/Library/Application\ Support/com.apple.TCC/TCC.db \
    /Users/*/Library/Safari/History.db; do
    if [[ -f "$P" ]]; then
      if /usr/bin/head -c 1 "$P" >/dev/null 2>&1; then
        printf 'READABLE: %s\n' "$P"
      else
        printf 'NOT_READABLE: %s\n' "$P"
      fi
    else
      printf 'NOT_VISIBLE_OR_ABSENT: %s\n' "$P"
    fi
  done
  printf '\nPermissions were not changed. Consult collection logs for other gaps.\n'
} > "$PREFLIGHT" 2>&1
/bin/cp "$PREFLIGHT" "$RUN/preflight.txt" || fail 'Cannot stage preflight.'
/bin/cp "$STATUS" "$RUN/run-start.txt" || fail 'Cannot stage run identity.'
printf '%s\n' "Collecting offline to $PARTIAL" "Diagnostics: $LOG"
"$BIN" --definitions "$BASE/artifacts" --nocolor --tempdir "$RUN" \
  artifacts collect DFIRSpeedrun.MacOS.Triage \
  --args "RunDirectory=$RUN" --require_admin \
  --timeout 1800 --progress_timeout 300 --format json \
  --output "$PARTIAL" > "$LOG" 2>&1 &
CHILD=$!
wait "$CHILD"
RC=$?
CHILD=
printf 'collector_exit_code=%s\nended_utc=%s\n' "$RC" "$(/bin/date -u +%FT%TZ)" >> "$STATUS"
if [[ $RC -ne 0 || ! -s "$PARTIAL" ]]; then
  printf 'state=FAILED\n' >> "$STATUS"
  printf '%s\n' "Collection failed. Preserve $STEM.* and $RUN" >&2
  exit 1
fi
# Test the container without extracting untrusted evidence onto this host.
if ! /usr/bin/unzip -tqq "$PARTIAL" >> "$LOG" 2>&1; then
  printf 'state=INVALID_ZIP\n' >> "$STATUS"
  printf '%s\n' "ZIP validation failed. Preserve $STEM.* and $RUN" >&2
  exit 1
fi
/bin/mv "$PARTIAL" "$FINAL" || fail 'Cannot finalize ZIP.'
printf 'state=PACKAGED_REVIEW_REQUIRED\n' >> "$STATUS"
printf '%s\n' 'ZIP creation succeeded. This does not prove all sources were collected.' >> "$STATUS"
printf '%s\n' 'Review preflight, RawArtifacts decisions, command return codes, and ZIP logs.' >> "$STATUS"
(
  cd "$BASE" || exit 1
  /usr/bin/shasum -a 256 "${FINAL##*/}" "${LOG##*/}" "${STATUS##*/}" "${PREFLIGHT##*/}"
) > "$STEM.sha256" || fail 'Evidence hashing failed.'
# Preserve the private workspace: SQLite/temp files may be evidence after errors.
printf '%s\n' "Created: $FINAL" "Preserve: $STEM.*" "Private temporary workspace: $RUN" \
  'Review collection gaps before treating this acquisition as complete.'
exit 0

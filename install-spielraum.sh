#!/bin/bash
set -euo pipefail

marketplace="am29d-plugins"
plugin="spielraum-chatgpt"
source_url="https://github.com/am29d/chatgpt-plugins.git"
bundled_codex="/Applications/ChatGPT.app/Contents/Resources/codex-cli/bin/codex"

fail() {
  printf 'Spielraum install: %s\n' "$1" >&2
  exit 1
}

if [[ $# -ne 0 ]]; then
  [[ $# -eq 2 && $1 == --codex-path ]] || fail "Usage: bash install-spielraum.sh [--codex-path PATH]"
  codex_cli="$2"
elif [[ -n ${CODEX_CLI_PATH:-} && -x $CODEX_CLI_PATH ]]; then
  codex_cli="$CODEX_CLI_PATH"
elif [[ -x $bundled_codex ]]; then
  codex_cli="$bundled_codex"
else
  codex_cli="$(type -P codex || true)"
fi
[[ -n $codex_cli && -f $codex_cli && -x $codex_cli ]] ||
  fail "Codex CLI was not found. Use a local Codex session with a CLI or pass --codex-path."
[[ -x /usr/bin/plutil ]] || fail "This installer requires macOS."

run_json() {
  local output
  if ! output="$("$codex_cli" "$@" --json)"; then
    [[ -z $output ]] || printf '%s\n' "$output" >&2
    fail "Codex failed while running: $*"
  fi
  printf '%s\n' "$output"
}

json_field() {
  /usr/bin/plutil -extract "$2" raw -expect "$3" -o - - <<< "$1"
}

registration="$(run_json plugin marketplace add "$source_url" --ref main)"
[[ $(json_field "$registration" marketplaceName string) == "$marketplace" ]] ||
  fail "Codex returned an unexpected marketplace."
already_added="$(json_field "$registration" alreadyAdded bool)"
if [[ $already_added == true ]]; then
  refresh="$(run_json plugin marketplace upgrade "$marketplace")"
  if [[ $(json_field "$refresh" errors array) != 0 ]]; then
    printf '%s\n' "$refresh" >&2
    fail "Codex could not refresh the marketplace."
  fi
fi

marketplace_root="$(json_field "$registration" installedRoot string)"
[[ -n $marketplace_root ]] || fail "Codex did not return a marketplace path."
manifest="$marketplace_root/plugins/$plugin/plugin.json"
expected_version="$(/usr/bin/plutil -extract version raw -expect string -o - "$manifest")"
[[ -n $expected_version ]] || fail "The marketplace plugin manifest has no version."
result="$(run_json plugin add "$plugin@$marketplace")"
installed_version="$(json_field "$result" version string)"
[[ $(json_field "$result" pluginId string) == "$plugin@$marketplace" &&
   $installed_version == "$expected_version" ]] ||
  fail "Codex did not report the expected plugin and version."

status="$(run_json plugin list --marketplace "$marketplace")"
installed_count="$(json_field "$status" installed array)"
for ((i = 0; i < installed_count; i++)); do
  if [[ $(json_field "$status" "installed.$i.pluginId" string) == "$plugin@$marketplace" &&
        $(json_field "$status" "installed.$i.version" string) == "$installed_version" &&
        $(json_field "$status" "installed.$i.enabled" bool) == true ]]; then
    printf 'Installed and enabled Spielraum %s. Start a new local Codex chat to load it.\n' "$installed_version"
    exit 0
  fi
done
fail "Codex did not confirm that Spielraum $installed_version is enabled."

# Spielraum desktop beta

Model and furnish a home through chat, then explore it in an interactive 2D/3D
planner. Each signed-in account keeps its own saved home on this computer.

## Requirements and setup

- A supported desktop host with local MCP plugin execution and MCP App UI.
- macOS with an available Node.js **24+** runtime including `node:sqlite`. The launcher prefers the desktop host runtime; no Bun or Node runtime is bundled.
- Access to the private `am29d/chatgpt-plugins` GitHub repository.
- An invited Spielraum Clerk beta account and connectivity for sign-in/revalidation.
- macOS Keychain access. Windows/Linux credential adapters are pending for this Node candidate; there is no plaintext fallback.

Follow the [marketplace installation instructions](../../README.md), install
`spielraum-chatgpt@am29d-plugins`, and start a new chat. Ask:

> Open Spielraum and help me create my home.

The first launch asks you to sign in. Choose **Sign in**, then **Continue in browser**
and approve the code shown in Spielraum. Use your invited account; accept its
invitation first if needed. A new signed-in account opens an empty workspace.
No example home or developer data is included. You do not need a source checkout, `node_modules`, an OpenAI API key or
a separately running preview server. ChatGPT provides the model; the plugin runs
planner tools locally. The source code is private; the bundled JavaScript remains
inspectable.

## Saved homes and updates

The home, undo history and preferences are stored in
`~/.local/share/spielraum/profiles/<account-hash>/workspace.sqlite`, outside the plugin installation.
Updates replace the plugin files while preserving that directory. Multiple chats
and local plugin processes share the currently signed-in account's home.
**Sign out** clears device credentials and preserves homes. Account switching
opens a separate profile. This does not encrypt homes or protect them from the
local OS user.

The old anonymous `~/.local/share/spielraum/workspace.sqlite` remains untouched
and is never assigned to the first login. Importing it needs explicit ownership
selection. `auth.sqlite` holds only device-session coordination; identity and
refresh tokens are stored in the OS credential store.

Quit the desktop host and any Spielraum preview processes before copying the data
directory for a manual backup. Preserve the whole directory, including any SQLite
WAL files. Keep a backup before upgrading; older versions may not be able to open
a database migrated by a newer version. Undo history is not a backup.

## Current beta boundaries

- Clerk currently targets the Spielraum **development** instance. Revalidation
  happens after at most ten minutes of active use or sooner at token expiry.
  Edits do not contact Clerk each time. Outages block access once revalidation is
  due and preserve saved homes. Live revocation timing still needs verification.
- Someone controlling the local executable can modify it to bypass the gate.
  The older `0.7.0-beta.1` release has no login gate.
- Cloud backup, cross-device sync and a hosted ChatGPT web app are not included.
- Embedded keyboard defaults remain disabled; use Search, Undo/Redo and other
  visible controls. Custom shortcut compatibility still needs real-host validation.
- If runtime discovery fails, update the desktop host or configure `CODEX_MCP_NODE_PATH` to an existing Node.js 24+ executable. Do not paste credentials into chat.
- OS/host coverage is limited to the verification documented for each release;
  the package being JavaScript is not proof of Windows/Linux host compatibility.

`SHA256SUMS` records this package's files. On macOS, run `shasum -a 256 -c
SHA256SUMS` from this directory to check them. Third-party licenses are in
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).

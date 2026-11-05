# Spielraum desktop beta

Model and furnish a home through chat, then explore it in an interactive 2D/3D
planner. Each OS user keeps their own saved home on their computer.

## Requirements and setup

- A supported desktop host with local MCP plugin execution and MCP App UI.
- Bun **1.4.4**, available as `bun` to the desktop application. Install Bun from
  [bun.sh](https://bun.sh/docs/installation) and verify with `bun --version`.
- Access to the private `am29d/chatgpt-plugins` GitHub repository.

Follow the [marketplace installation instructions](../../README.md), install
`spielraum-chatgpt@am29d-plugins`, and start a new chat. Ask:

> Open Spielraum and help me create my home.

The first launch shows an empty workspace. No example home or developer data is
included. You do not need a source checkout, `node_modules`, an OpenAI API key or
a separately running preview server. ChatGPT provides the model; the plugin runs
planner tools locally. The source code is private; the bundled JavaScript remains
inspectable.

## Saved homes and updates

The home, undo history and preferences are stored in
`~/.local/share/spielraum/workspace.sqlite`, outside the plugin installation.
Updates replace the plugin files while preserving that directory. Multiple chats
and local plugin processes share the same home for that OS user. Different people
using the same OS account currently share the home.

Quit the desktop host and any Spielraum preview processes before copying the data
directory for a manual backup. Preserve the whole directory, including any SQLite
WAL files. Keep a backup before upgrading; older versions may not be able to open
a database migrated by a newer version. Undo history is not a backup.

## Current beta boundaries

- Clerk sign-in and account-specific local profiles are not implemented. Access to
  the private GitHub repository controls downloads, not the use of a copied package.
- Cloud backup, cross-device sync and a hosted ChatGPT web app are not included.
- Embedded keyboard defaults remain disabled; use Search, Undo/Redo and other
  visible controls. Custom shortcut compatibility still needs real-host validation.
- Bun is required. If startup reports `bun` missing, ensure the desktop app can
  find it on its PATH and restart the app. Do not paste credentials into chat.
- OS/host coverage is limited to the verification documented for each release;
  the package being JavaScript is not proof of Windows/Linux host compatibility.

`SHA256SUMS` records this package's files. On macOS, run `shasum -a 256 -c
SHA256SUMS` from this directory to check them. Third-party licenses are in
[`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md).

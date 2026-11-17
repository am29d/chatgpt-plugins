# Alex's ChatGPT Plugins

A custom marketplace for prebuilt desktop plugins. Application source and Git
history are maintained separately; this repository contains installable packages,
plugin instructions, assets and third-party notices. Built JavaScript can be
inspected.

## Install

### Quick install with one prompt

Paste this into Codex on macOS or Windows:

> Install Spielraum from the public `am29d/chatgpt-plugins` marketplace, open it, and guide me through sign-in.

Spielraum finds Node 24+ with built-in SQLite automatically, preferring the desktop
host's runtime, then known Codex runtime locations, then PATH. The package contains
no runtime or compiled helper. Bun is not required to run the plugin.
An invited Spielraum beta account is required to sign in.

### Current tester build: 0.8.0-node.10

This build combines the current planner UI, including the fine white furniture selection contour, updated furniture controls and R/D/X actions, with the Windows login implementation. Install or update Spielraum, restart the desktop app or start a fresh chat, and sign in with an invited beta account. Check that the planner opens, then restart the app and check that the session and home are restored.

Credentials use Windows DPAPI protection tied to your Windows user. The system-provided Windows PowerShell must be available; no manual script setup or separate helper installation is needed. Windows installation and browser sign-in with node.9 were confirmed by a tester. Restart persistence, sign-out and rendering still need acceptance in the target desktop host.

For a Windows test, paste this into Codex:

> Update Spielraum from the public `am29d/chatgpt-plugins` marketplace to version `0.8.0-node.10`, open it, and guide me through sign-in. Help me check restart persistence and sign-out without deleting my home.

The Clerk page still shows Development mode because this beta uses the Spielraum development instance.

### Manual install

In Codex, add the public marketplace:

```sh
codex plugin marketplace add am29d/chatgpt-plugins --ref main
```

Open the desktop Plugins directory, choose **Alex's ChatGPT Plugins**, and install
the desired plugin. The installed CLI also supports:

```sh
codex plugin add spielraum-chatgpt@am29d-plugins
```

Start a new chat after installation. If the desktop app has cached the marketplace
or tools, restart it. In Codex CLI, `/plugins` also lists marketplace entries;
use a supported desktop app to view interactive planner UI.

The catalog is [`.agents/plugins/marketplace.json`](.agents/plugins/marketplace.json).
Plugin-specific setup and limitations are documented in each `plugins/<name>/README.md`.
For Spielraum, see [its installation guide](plugins/spielraum-chatgpt/README.md).

## Update

```sh
codex plugin marketplace upgrade am29d-plugins
codex plugin add spielraum-chatgpt@am29d-plugins
```

Confirm that the installed Spielraum version is `0.8.0-node.10`, then fully restart the desktop app and start a new session. An already-running conversation can keep the previous plugin process and UI loaded. For a fixed release,
add the marketplace with `--ref <release-tag>` instead of `--ref main`. Tags identify
immutable marketplace snapshots; use `main` for the latest catalog.

## Adding more plugins

Keep each package under `plugins/<plugin-name>/` and give it its own catalog entry.
Update only the intended plugin directory and catalog entry. Preserve other plugins,
their versions and the marketplace's stable name, `am29d-plugins`.

No credentials, saved homes, source maps, source checkout or `node_modules` belong
in this repository. This repository does not grant an open-source license to the
plugins; bundled third-party code retains its accompanying license terms.

# Alex's ChatGPT Plugins

A custom marketplace for prebuilt desktop plugins. Application source and Git
history are maintained separately; this repository contains installable packages,
plugin instructions, assets and third-party notices. Built JavaScript can be
inspected.

## Install

You need a desktop host that supports local MCP plugins, Git, and each plugin's
runtime prerequisites. This is not a ChatGPT web/mobile installation.

This beta repository is private. Your GitHub account must have repository access,
and Git must be able to authenticate before adding the marketplace. Repository
access currently controls distribution; Spielraum's Clerk login is not implemented.

With an authenticated HTTPS Git setup:

```sh
codex plugin marketplace add am29d/chatgpt-plugins --ref main
```

Or, if your GitHub access uses SSH:

```sh
codex plugin marketplace add git@github.com:am29d/chatgpt-plugins.git --ref main
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

Restart the desktop app or start a new session after updating. For a fixed release,
add the marketplace with `--ref <release-tag>` instead of `--ref main`. Tags identify
immutable marketplace snapshots; use `main` for the latest catalog.

## Adding more plugins

Keep each package under `plugins/<plugin-name>/` and give it its own catalog entry.
Update only the intended plugin directory and catalog entry. Preserve other plugins,
their versions and the marketplace's stable name, `am29d-plugins`.

No credentials, saved homes, source maps, source checkout or `node_modules` belong
in this repository. This repository does not grant an open-source license to the
plugins; bundled third-party code retains its accompanying license terms.

# Browser Extension

Chrome/Edge (MV3, load unpacked) and Firefox (temporary add-on via
web-ext).

## Install (development mode)

1. Open `chrome://extensions/` (or `edge://extensions/`).
2. Enable **Developer mode**.
3. Click **Load unpacked** and select `browser-extension/`.

Firefox: `web-ext run --source-dir browser-extension` or load
`about:debugging#/runtime/this-firefox` -> Load Temporary Add-on ->
`browser-extension/manifest.json`.

## What it does

- Detects GitLab pages (self-managed or GitLab.com).
- Injects the RST stylesheet (`styles.css`), the same CSS the server-side
  solution uses, so docutils output (admonitions, tables, sidebars,
  field lists, ...) is styled everywhere in the UI.
- Tags `.rst` blob viewers with the `rst-enhanced` class.
- Re-runs on GitLab's soft (Turbo-style) navigations.

## Configuration

- Popup: global on/off toggle plus per-site enable/disable for the
  current host.
- Options page (right-click the extension icon -> Options): manage the
  full allow-list of GitLab hosts, one per line.

## Icons

Add PNG icons (16/48/128) and reference them under `icons` in
`manifest.json` before publishing to the Chrome Web Store.

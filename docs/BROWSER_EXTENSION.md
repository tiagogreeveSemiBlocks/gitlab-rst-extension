# Browser Extension

Chrome/Edge (MV3, load unpacked) and Firefox (temporary add-on, or signed
with web-ext).

## Firefox

### 1. Load the extension

- Temporary: `about:debugging#/runtime/this-firefox` -> **Load Temporary
  Add-on** -> `browser-extension/manifest.json`.
- Or permanent dev install: `web-ext run --source-dir browser-extension`.

Temporary add-ons vanish when Firefox restarts.

### 2. Grant host permissions (required!)

Firefox treats MV3 `host_permissions` as **optional**: the content
script is never injected until access is granted. Two ways:

- Click the extension icon -> **Grant access to all sites** (calls
  `browser.permissions.request`), then reload open GitLab tabs.
- Or `about:addons` -> GitLab RST Enhanced -> **Permissions** tab ->
  enable **Access your data for all websites**.

Chrome grants host permissions automatically on install; this step is
Firefox-only.

### 3. Verify

On a GitLab page, DevTools console:

```js
document.body.classList.contains("rst-enhanced-page") // true
document.getElementById("gitlab-rst-enhanced-style")   // <style>
````

If the style tag is missing, the most likely cause is ungranted host
permissions (step 2), not the detection heuristic.

## Chrome / Edge

1. Open `chrome://extensions/` (or `edge://extensions/`).
2. Enable **Developer mode**.
3. Click **Load unpacked** and select `browser-extension/`.

## What it does

- Detects GitLab pages (self-managed or GitLab.com): DOM markers or
  `/-/` and `.rst` URL patterns.
- Injects the RST stylesheet (`styles.css`), the same CSS the
  server-side solution uses, so docutils output (admonitions, tables,
  sidebars, field lists, ...) is styled everywhere in the UI.
- Tags `.rst` blob viewers with the `rst-enhanced` class.
- Re-runs on GitLab's soft (Turbo-style) navigations and immediately
  when settings change.

## Configuration

- Popup: global on/off toggle, per-site enable/disable for the current
  tab's host, and the Firefox permission grant button.
- Options page (right-click the extension icon -> Options): manage the
  full allow-list of GitLab hosts, one per line.

## Icons

Add PNG icons (16/48/128) and reference them under `icons` in
`manifest.json` before publishing to the Chrome Web Store or AMO.

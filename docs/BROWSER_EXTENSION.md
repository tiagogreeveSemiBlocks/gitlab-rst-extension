# Browser Extension

Chrome/Edge (MV3, load unpacked) and Firefox (temporary add-on, or signed
with web-ext).

## Icons

`icons/icon.svg` is the extension icon (GitLab-orange document with an
RST badge). Firefox supports SVG icons directly; Chrome accepts SVG in
recent versions. Before publishing to the Chrome Web Store or AMO, export
PNG copies (16/48/128 px) and update the `icons` entries.

## Firefox

### 1. Load the extension

- Temporary: `about:debugging#/runtime/this-firefox` -> **Load Temporary
  Add-on** -> `browser-extension/manifest.json`.
- Or: `web-ext run --source-dir browser-extension`.

Temporary add-ons vanish when Firefox restarts and NEVER auto-update:
after pulling new code you must **Remove** the old entry and **Reload**
the add-on (about:debugging), or re-load the manifest.

### 2. Grant host permissions (required!)

Firefox treats MV3 `host_permissions` as **optional**: the content
script never runs until access is granted.

- Click the toolbar icon -> **Grant access to all sites**, then reload
  open GitLab tabs; or
- `about:addons` -> GitLab RST Enhanced -> **Permissions** -> enable
  **Access your data for all websites**.

### 3. Opening settings

Click the toolbar icon: a small popup opens with a global toggle and
per-site buttons. On Firefox versions where the popup does not attach
(a known MV3 flakiness), clicking the icon instead opens the full
options page (background fallback). You can always reach it via
`about:addons` -> GitLab RST Enhanced -> Options.

### 4. Verify

On a GitLab page, DevTools console:

```js
document.body.classList.contains("rst-enhanced-page") // true
document.getElementById("gitlab-rst-enhanced-style")   // <style>
```

If the style tag is missing, the most likely cause is ungranted host
permissions (step 2), not the detection heuristic.

### 5. Firefox Flatpak: load from a sandbox-readable path

If Firefox is installed as a **Flatpak**, it runs in a filesystem
sandbox. A temporary add-on can be *loaded* from any directory (the
file chooser bypasses the sandbox), but Firefox then fails to read the
extension's own files. Symptoms: blank toolbar icon, blank options
page, popup does nothing, and the content script never runs - while
`ls` on the host shows all files present.

Diagnosis: open the icon directly in a tab:

```
file:///<repo-path>/browser-extension/icons/icon.svg
```

If Firefox shows "file not found" while the file exists on disk, the
sandbox cannot read that directory.

Fix: expose the repo path to Firefox, fully restart it, and re-load the
add-on:

```bash
flatpak override --user --filesystem=/<repo-path> org.mozilla.firefox
flatpak kill org.mozilla.firefox   # fully quit, then relaunch
```

Undo with `flatpak override --user --reset org.mozilla.firefox`.
Alternatively, copy `browser-extension/` to a location the sandbox
already exposes (e.g. `~/.local/share/gitlab-rst-extension`) and load
that copy, or use a native (deb/rpm) Firefox for extension development.

## Chrome / Edge

1. Open `chrome://extensions/` (or `edge://extensions/`).
2. Enable **Developer mode**.
3. Click **Load unpacked** and select `browser-extension/`.
4. After pulling updates, click the extension's **Reload** (circular
   arrows) icon on the chrome://extensions card.

## What it does

- Detects GitLab pages (self-managed or GitLab.com): DOM markers or
  `/-/` and `.rst` URL patterns.
- Injects the RST stylesheet (`styles.css`), the same CSS the
  server-side solution uses, so docutils output (admonitions, tables,
  sidebars, field lists, ...) is styled everywhere in the UI.
- Tags `.rst` blob viewers with the `rst-enhanced` class.
- Re-runs on GitLab's soft (Turbo-style) navigations and immediately
  when settings change.

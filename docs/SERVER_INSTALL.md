# Server-Side Install (Self-Managed GitLab)

Goal: full reStructuredText rendering of `.rst` files and READMEs in the
GitLab UI, with styled admonitions, tables, sidebars, code blocks and more.

## How GitLab renders RST today

GitLab renders `.rst` blobs by spawning a `python3` docutils process from
the gitlab-markup gem. If `python3` + docutils are missing on the host, RST
files fall back to plain text.

Two things then break full RST rendering:

1. **Sanitization**: Banzai's SanitizationFilter UNWRAPS `<div>` elements.
   Docutils emits admonitions, sidebars, topics and rubrics as divs with
   semantic classes - the sanitizer removes the divs and their classes,
   so they collapse into plain paragraphs. This is why a rendered RST
   blob shows real tables but unstyled "Be careful." text under warnings.
2. **Styling**: even where elements survive, GitLab ships no CSS for
   docutils' classes.

This project fixes both: the initializer extends the sanitization
allowlist (divs and classes survive) and the RST stylesheet is injected
(they get styled).

## 1. Quick start (script)

```bash
sudo ./install/omnibus-install.sh
````

The script:

1. Installs `python3` and `python3-docutils`.
2. Copies the enhanced renderer to `/usr/local/lib/gitlab-rst-enhanced`.
3. Drops a Rails initializer into
   `/opt/gitlab/embedded/service/gitlab-rails/config/initializers/` that
   wraps `gitlab-markup`'s `.rst` rendering AND extends the Banzai
   sanitization allowlist.
4. Restarts `gitlab-rails`.

Re-run the script after every GitLab upgrade (Omnibus restores its
config directory on upgrade).

## 2. What the initializer does

gitlab-markup exposes one public entry point, `Markup.render(filename,
content)`. The initializer wraps it: `.rst` files go through
`Gitlab::RstEnhanced.render` (our hardened docutils renderer); every
other markup language falls through untouched. Because it patches the
public API, it survives gitlab-markup internal changes.

The initializer also registers
`Banzai::Filter::SanitizationFilter.custom_allowlist`, adding `div`,
`aside`, `figure`, `figcaption` and the `class` attribute to the
allowlist, so docutils' structural markup survives sanitization.

## 3. Security

The enhanced renderer keeps GitLab's restrictions:

- The `raw` directive is disabled (no arbitrary HTML injection).
- The `include` directive is disabled (no reading host files).
- Warnings/system messages are never written into the HTML.
- All other elements still pass through Banzai sanitization unchanged.

Note: allowing `div`/`aside` with `class` widens what rendered RST can
contain structurally; the enhanced renderer itself never emits scripts,
event handlers or inline styles, and `raw` remains disabled, so no
untrusted HTML enters the pipeline through RST.

## 4. Styling: inject the RST stylesheet

With the allowlist extended, docutils classes survive to the browser.
The remaining piece is CSS. Two options:

**Option A - NGINX sub_filter (recommended, no Rails patching).** In
`/etc/gitlab/gitlab.rb`:

```ruby
nginx['custom_nginx_config'] = "sub_filter '</head>' '<link rel=\"stylesheet\" href=\"https://gitlab.example.com/uploads/-/system/rst-enhanced.css\"></head>'; sub_filter_once on;"
nginx['gzip_enabled'] = false # sub_filter needs uncompressed responses
````

(Host `rst-enhanced.css` anywhere reachable; e.g. a project upload, an
artifacts URL, or a small static file server.)

Then `sudo gitlab-ctl reconfigure`.

**Option B - browser extension.** The companion browser extension injects
the exact same stylesheet client-side. Use it if you cannot touch NGINX,
or on GitLab.com.

## 5. Why the browser extension alone is not enough

The extension can only style what reaches the browser. Before the
initializer is installed, GitLab's sanitizer has already unwrapped the
admonition/sidebar divs server-side, so there is nothing left for client
CSS to target. Full RST rendering (structure + styling) requires the
server-side component; the extension complements it by injecting the
stylesheet without NGINX changes and by covering additional surfaces.

## 6. Verify

Push `test-sample/README.rst` to a project. You should see: colored
admonitions, bordered striped tables, boxed literal blocks, a styled
sidebar/topic/field list.

If admonitions still render as plain paragraphs: the initializer did not
load - check `sudo gitlab-ctl tail gitlab-rails` for the
"[rst-enhanced]" log lines after restart.
If the structure is right but uncolored: only the stylesheet (step 4) is
missing.

## 7. Scope and limits

Fully server-side rendered surfaces: repository `.rst` files, README.rst,
index.rst, and any markup-rendered blob.

Issues, merge request descriptions/comments, and wiki pages are
Markdown-only inside GitLab's Rails app - GitLab has no server-side
extension point for RST there, and that cannot be changed without
patching GitLab core. The companion browser extension covers those
surfaces client-side (styled blocks), or contributors can write Markdown
with fenced RST kept in `.rst` files. See docs/LIMITATIONS.md.

## 8. Uninstall

```bash
sudo rm /opt/gitlab/embedded/service/gitlab-rails/config/initializers/rst_enhanced.rb
sudo rm -rf /usr/local/lib/gitlab-rst-enhanced /usr/local/bin/rst2html-enhanced /usr/local/share/gitlab-rst-enhanced
sudo gitlab-ctl restart gitlab-rails
```

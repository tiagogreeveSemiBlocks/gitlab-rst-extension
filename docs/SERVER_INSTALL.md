# Server-Side Install (Self-Managed GitLab)

Goal: full reStructuredText rendering of `.rst` files and READMEs in the
GitLab UI, with styled admonitions, tables, sidebars, code blocks and more.

## How GitLab renders RST today

GitLab renders `.rst` blobs by spawning a `python3` docutils process from
the gitlab-markup gem. If `python3` + docutils are missing on the host, RST
files fall back to plain text. Docutils emits semantic CSS classes
(`admonition warning`, `table`, `sidebar`, ...), and GitLab's sanitizer
keeps them, but GitLab ships no CSS for them - which is why RST looks
unstyled. This project fixes both sides.

## 1. Quick start (script)

```bash
sudo ./install/omnibus-install.sh
````

The script:

1. Installs `python3` and `python3-docutils`.
2. Copies the enhanced renderer to `/usr/local/lib/gitlab-rst-enhanced`.
3. Drops a Rails initializer into
   `/opt/gitlab/embedded/service/gitlab-rails/config/initializers/` that
   wraps `gitlab-markup`'s `.rst` rendering.
4. Restarts `gitlab-rails`.

Re-run the script after every GitLab upgrade (Omnibus restores its
config directory on upgrade).

## 2. What the initializer does

gitlab-markup exposes one public entry point, `Markup.render(filename,
content)`. The initializer wraps it: `.rst` files go through
`Gitlab::RstEnhanced.render` (our hardened docutils renderer); every
other markup language falls through untouched. Because it patches the
public API, it survives gitlab-markup internal changes.

## 3. Security

The enhanced renderer keeps GitLab's restrictions:

- The `raw` directive is disabled (no arbitrary HTML injection).
- The `include` directive is disabled (no reading host files).
- Warnings/system messages are never written into the HTML.
- Output passes through GitLab's normal Banzai sanitization.

## 4. Styling: inject the RST stylesheet

Docutils classes survive sanitization, so the only missing piece is CSS.
Two options:

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

## 5. Verify

Push `test-sample/README.rst` to a project. You should see: colored
admonitions, bordered striped tables, boxed literal blocks, a styled
sidebar/topic/field list. If the structure is right but unstyled, only
step 4 is missing.

## 6. Scope and limits

Fully server-side rendered surfaces: repository `.rst` files, README.rst,
index.rst, and any markup-rendered blob.

Issues, merge request descriptions/comments, and wiki pages are
Markdown-only inside GitLab's Rails app - GitLab has no server-side
extension point for RST there, and that cannot be changed without
patching GitLab core. The companion browser extension covers those
surfaces client-side (styled blocks), or contributors can write Markdown
with fenced RST kept in `.rst` files. See docs/LIMITATIONS.md.

## 7. Uninstall

```bash
sudo rm /opt/gitlab/embedded/service/gitlab-rails/config/initializers/rst_enhanced.rb
sudo rm -rf /usr/local/lib/gitlab-rst-enhanced /usr/local/bin/rst2html-enhanced /usr/local/share/gitlab-rst-enhanced
sudo gitlab-ctl restart gitlab-rails
```

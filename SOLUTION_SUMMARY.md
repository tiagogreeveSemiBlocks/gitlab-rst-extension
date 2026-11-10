# Solution Summary

## Problem

GitLab renders `.rst` files via python3 docutils (gitlab-markup), but:
1. If python3-docutils is missing on the host, RST does not render at all.
2. Docutils output is unstyled - admonitions appear as plain paragraphs,
   tables have no borders, sidebars/topics/field lists are invisible.
3. Issues, MRs, descriptions and wiki pages are Markdown-only; there is
   no server-side hook for RST there.

## Solution

Two complementary components:

### Server-side (self-managed) - the core fix
- Hardened docutils renderer (`bin/rst2html-enhanced`): semantic classes
  kept, `raw`/`include` disabled, warnings suppressed.
- Rails initializer wrapping gitlab-markup's public `render` API so all
  `.rst` rendering goes through the enhanced renderer.
- RST stylesheet injected via NGINX `sub_filter` (or the browser
  extension).
- One-command Omnibus installer: `install/omnibus-install.sh`.

### Client-side (any GitLab) - the gap-filler
- MV3 browser extension injecting the same stylesheet on any GitLab
  host, with per-site and global toggles - covers GitLab.com, locked-down
  instances, and the Markdown-only surfaces where the server cannot help.

## Security

- `raw` and `include` directives disabled.
- No file reads, no network calls, no arbitrary HTML.
- All output still sanitized by GitLab's Banzai pipeline.

## Verifying

Push `test-sample/README.rst` and check that admonitions are colored and
tables are striped and bordered.

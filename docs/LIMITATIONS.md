# Scope & Limitations

## Where full RST rendering is possible

| Surface | Server-side | Notes |
|---|---|---|
| Repository `.rst` files | Yes | docutils via gitlab-markup; enabled by installing python3-docutils |
| README.rst / index.rst | Yes | Same path as blob rendering |
| Snippets with .rst extension | Yes | Markup-rendered like blobs |
| Issues / MRs / epics | No (Markdown only) | GitLab hardcodes GitLab Flavored Markdown; no plugin API |
| Wiki pages | No (Markdown only) | Same reason |
| MR diffs | No | Diffs are line-based by design |

## Why "everything" needs the browser extension

GitLab's Rails application renders issues, MR descriptions, comments and
wiki pages through the Banzai pipeline, which is GitLab Flavored Markdown
only. There is no supported server-side extension point to swap in a
different markup language per-content. Changing it means patching GitLab
core, which breaks on every upgrade and is not supportable.

The browser extension provides the client-side half: it injects the full
RST stylesheet into GitLab pages, so any RST-rendered content (and
content pasted into those surfaces with the extension's styling) looks
right, on any GitLab instance, without server access.

## Security posture

- `raw` directive disabled - no arbitrary HTML.
- `include` directive disabled - no host file reads.
- All output still passes through GitLab's Banzai sanitization filter.
- The renderer never makes network calls.

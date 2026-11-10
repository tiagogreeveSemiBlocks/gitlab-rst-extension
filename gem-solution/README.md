# gitlab-rst-enhanced (Ruby gem / server-side solution)

Enhanced reStructuredText rendering for self-managed GitLab.

## What it is

- `bin/rst2html-enhanced` - hardened docutils renderer: reads RST on
  stdin, writes a styled HTML fragment to stdout. Disables `raw` and
  `include`, suppresses system messages, keeps docutils' semantic CSS
  classes.
- `lib/gitlab/rst_enhanced.rb` - Ruby wrapper plus `install!`, which
  wraps gitlab-markup's public `render(filename, content)` API so
  `.rst` goes through the enhanced renderer.
- `assets/rst-enhanced.css` - the RST stylesheet (also used by the
  browser extension and the NGINX injection).

## Install into GitLab

See `docs/SERVER_INSTALL.md`. Short version for source installs:

```bash
gem build gitlab-rst-enhanced.gemspec
gem install gitlab-rst-enhanced-1.0.0.gem
````

then add `config/initializers/rst_enhanced.rb`:

```ruby
require "gitlab/rst_enhanced"
Gitlab::RstEnhanced.install!
````

Requires `python3` + docutils (`python3-docutils`) on the GitLab host.

## Standalone preview

```bash
echo ".. warning:: check this" | ./bin/rst2html-enhanced --full-page > preview.html
```

## Tests

```bash
bundle install
rake spec
````
(Test suite requires python3 + docutils installed.)

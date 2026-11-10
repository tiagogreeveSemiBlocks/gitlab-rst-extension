# config/initializers/rst_enhanced.rb
#
# Enhanced reStructuredText rendering for GitLab (self-managed).
# Requires the gitlab-rst-enhanced files and the python3-docutils package
# on the GitLab host. See docs/SERVER_INSTALL.md.

require "gitlab/rst_enhanced" # gem install, or an absolute path require for Omnibus

Gitlab::RstEnhanced.install!

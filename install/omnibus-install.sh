#!/usr/bin/env bash
#
# Server-side install for self-managed Omnibus GitLab.
# Run as root on the GitLab host. Re-run after every GitLab upgrade
# (Omnibus overwrites config/initializers on upgrade).
#
# See docs/SERVER_INSTALL.md for the full guide and the optional NGINX
# CSS injection step.

set -euo pipefail

GEM_DIR="/usr/local/lib/gitlab-rst-enhanced"
INIT_FILE="/opt/gitlab/embedded/service/gitlab-rails/config/initializers/rst_enhanced.rb"
SCRIPT_DST="/usr/local/bin/rst2html-enhanced"
CSS_DST="/usr/local/share/gitlab-rst-enhanced"

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this script as root." >&2
  exit 1
fi

echo "==> Installing python3 + docutils (enables and powers RST rendering)"
if command -v apt-get >/dev/null 2>&1; then
  apt-get update && apt-get install -y python3 python3-docutils
elif command -v dnf >/dev/null 2>&1; then
  dnf install -y python3 python3-docutils
else
  echo "Unsupported package manager; install python3 and docutils manually." >&2
  exit 1
fi

echo "==> Installing enhanced renderer to ${GEM_DIR}"
mkdir -p "${GEM_DIR}" "${CSS_DST}"
cp -r gem-solution/lib gem-solution/bin gem-solution/assets "${GEM_DIR}/"
cp -r "${GEM_DIR}/bin/rst2html-enhanced" "${SCRIPT_DST}"
chmod +x "${SCRIPT_DST}"
cp "${GEM_DIR}/assets/rst-enhanced.css" "${CSS_DST}/rst-enhanced.css"
# Keep the script's relative CSS lookup working.
sed -i "s#\.\./assets/rst-enhanced.css#../assets/rst-enhanced.css#" "${SCRIPT_DST}" || true

echo "==> Adding Rails initializer (wraps gitlab-markup's .rst rendering)"
cat > "${INIT_FILE}" <<'EOF'
# Managed by gitlab-rst-extension. Enhanced RST rendering.
require "/usr/local/lib/gitlab-rst-enhanced/lib/gitlab/rst_enhanced"
Gitlab::RstEnhanced.install!
EOF

echo "==> Restarting GitLab"
gitlab-ctl restart gitlab-rails || gitlab-ctl restart

echo ""
echo "Done. Verify with a test .rst file (see test-sample/README.rst)."
echo "Optional next step: inject rst-enhanced.css via NGINX sub_filter so the"
echo "rendered classes get styled - see docs/SERVER_INSTALL.md section 4."

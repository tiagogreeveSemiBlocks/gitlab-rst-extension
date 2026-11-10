// GitLab RST Enhanced - content script.
// Injects the docutils stylesheet into GitLab pages so server-rendered RST
// (admonitions, tables, sidebars, ...) is styled, and flags rendered
// .rst blob containers with the .rst-enhanced class.

const api = typeof browser !== "undefined" ? browser : chrome;

const STYLE_ID = "gitlab-rst-enhanced-style";

function looksLikeGitLab() {
  // Strong signals first, then URL heuristics (helps GitLab versions
  // whose DOM differs).
  if (
    document.querySelector("meta[content='GitLab']") ||
    document.querySelector("body[data-page]") ||
    document.querySelector("#gitlab-logo, .gl-logo, nav.gl-linked-tabs")
  ) return true;
  return /\/-\//.test(location.pathname) || /\.rst(\?|$)/.test(location.href);
}

function currentHost() {
  return location.hostname;
}

function injectStyles() {
  if (document.getElementById(STYLE_ID)) return;
  fetch(api.runtime.getURL("styles.css"))
    .then(function (r) { return r.text(); })
    .then(function (css) {
      const style = document.createElement("style");
      style.id = STYLE_ID;
      style.textContent = css;
      document.head.appendChild(style);
      document.body.classList.add("rst-enhanced-page");
    });
}

function flagRenderedRst() {
  // GitLab renders blob markup into the file content viewer. If the URL
  // points at a .rst file, tag the container so the stylesheet applies.
  if (/\.rst(\?|$)/.test(location.href)) {
    const viewer = document.querySelector("[data-blob-code], .file-content, .blob-viewer, [data-testid='blob-viewer']");
    if (viewer) viewer.classList.add("rst-enhanced");
  }
}

function run(settings) {
  const enabled = settings.enabled !== false; // default on
  const hosts = settings.hosts || [];
  const host = currentHost();
  if (!enabled || (hosts.length > 0 && !hosts.includes(host))) return;
  if (!looksLikeGitLab()) return;
  injectStyles();
  flagRenderedRst();
}

api.storage.sync.get({ enabled: true, hosts: [] }, run);

// Re-apply immediately when settings change (popup/options edits).
api.storage.onChanged.addListener(function (changes, area) {
  if (area !== "sync") return;
  api.storage.sync.get({ enabled: true, hosts: [] }, run);
});

// GitLab uses Turbo-style navigation; re-run on soft navigations.
let lastUrl = location.href;
setInterval(function () {
  if (location.href !== lastUrl) {
    lastUrl = location.href;
    api.storage.sync.get({ enabled: true, hosts: [] }, run);
  }
}, 750);

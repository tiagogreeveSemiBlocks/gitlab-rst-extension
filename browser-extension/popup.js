// GitLab RST Enhanced - popup.
// Works in Firefox (browser.*) and Chrome (chrome.*) MV3.

const api = typeof browser !== "undefined" ? browser : chrome;

const hostEl = document.getElementById("host");
const permBox = document.getElementById("needs-permission");
const grantBtn = document.getElementById("grant");
const enabledEl = document.getElementById("enabled");
const toggleHostBtn = document.getElementById("toggle-host");
const statusEl = document.getElementById("status");

let currentHost = null;
let state = { enabled: true, hosts: [] };

function setState(next) {
  state = next;
  enabledEl.checked = state.enabled !== false;
  const allowed = state.hosts.length === 0 || state.hosts.includes(currentHost);
  toggleHostBtn.textContent = allowed
    ? "Disable on " + currentHost
    : "Enable on " + currentHost;
}

function getActiveTabHost() {
  return api.tabs.query({ active: true, currentWindow: true }).then(function (tabs) {
    const tab = tabs && tabs[0];
    if (!tab || !tab.url) return null;
    try { return new URL(tab.url).hostname; } catch (e) { return null; }
  });
}

function checkPermissions() {
  // Firefox MV3: host permissions are optional and NOT auto-granted.
  // If missing, the content script never runs.
  if (!api.permissions || !api.permissions.contains) return;
  api.permissions.contains({ origins: ["<all_urls>"] }).then(function (has) {
    if (has) return;
    if (currentHost) {
      permBox.hidden = false;
      statusEl.textContent = "";
    }
  });
}

grantBtn.addEventListener("click", function () {
  api.permissions.request({ origins: ["<all_urls>"] }).then(function (granted) {
    if (granted) {
      permBox.hidden = true;
      statusEl.textContent = "Access granted. Reload open GitLab tabs.";
    } else {
      statusEl.textContent = "Access denied; content script will not run.";
    }
  });
});

enabledEl.addEventListener("change", function () {
  api.storage.sync.set({ enabled: enabledEl.checked });
  statusEl.textContent = "Saved";
});

toggleHostBtn.addEventListener("click", function () {
  const hosts = new Set(state.hosts);
  if (hosts.has(currentHost)) hosts.delete(currentHost); else hosts.add(currentHost);
  const arr = Array.from(hosts);
  api.storage.sync.set({ hosts: arr });
  setState({ enabled: state.enabled, hosts: arr });
  statusEl.textContent = "Saved. Reload GitLab tabs to see the change.";
});

getActiveTabHost().then(function (host) {
  currentHost = host;
  hostEl.textContent = host || "(no active tab URL)";
  api.storage.sync.get({ enabled: true, hosts: [] }, setState);
  checkPermissions();
});

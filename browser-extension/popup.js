const hostEl = document.getElementById("host");
const enabledEl = document.getElementById("enabled");
const toggleHostBtn = document.getElementById("toggle-host");
const statusEl = document.getElementById("status");
const host = location.hostname || "this site";
const currentHost = new URLSearchParams(new URL(location.href).search).get("host");
// Popups have no location of the GitLab tab; use the active tab's host.
chrome.tabs.query({ active: true, currentWindow: true }, function (tabs) {
  const tab = tabs[0];
  if (!tab || !tab.url) return;
  const host = new URL(tab.url).hostname;
  hostEl.textContent = host;

  chrome.storage.sync.get({ enabled: true, hosts: [] }, function (s) {
    enabledEl.checked = s.enabled !== false;
    const allowed = s.hosts.includes(host);
    toggleHostBtn.textContent = allowed ? "Disable on this site" : "Enable on this site";

    enabledEl.addEventListener("change", function () {
      chrome.storage.sync.set({ enabled: enabledEl.checked });
      statusEl.textContent = "Saved";
    });

    toggleHostBtn.addEventListener("click", function () {
      const hosts = new Set(s.hosts);
      if (hosts.has(host)) { hosts.delete(host); } else { hosts.add(host); }
      const arr = Array.from(hosts);
      chrome.storage.sync.set({ hosts: arr }, function () {
        chrome.storage.sync.set({ hosts: arr });
        toggleHostBtn.textContent = hosts.has(host) ? "Disable on this site" : "Enable on this site";
        statusEl.textContent = "Saved";
      });
      s.hosts = arr;
    });
  });
});

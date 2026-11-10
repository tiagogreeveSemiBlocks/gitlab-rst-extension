// GitLab RST Enhanced - options page.
// Defensive: any unexpected failure is shown on the page instead of
// leaving it blank.

try {
  const api = typeof browser !== "undefined" ? browser : chrome;
  const enabledEl = document.getElementById("enabled");
  const hostsEl = document.getElementById("hosts");
  const saveBtn = document.getElementById("save");
  const statusEl = document.getElementById("status");

  function fail(msg) {
    statusEl.className = "muted error";
    statusEl.textContent = "Error: " + msg;
  }

  api.storage.sync.get({ enabled: true, hosts: [] }, function (s) {
    enabledEl.checked = s.enabled !== false;
    hostsEl.value = (s.hosts || []).join("\n");
  });

  saveBtn.addEventListener("click", function () {
    const hosts = hostsEl.value.split(/\s+/).filter(Boolean);
    api.storage.sync.set({ enabled: enabledEl.checked, hosts: hosts }, function () {
      if (api.runtime.lastError) {
        fail(api.runtime.lastError.message);
        return;
      }
      statusEl.className = "muted";
      statusEl.textContent = "Saved. Reload GitLab tabs.";
      setTimeout(function () { statusEl.textContent = ""; }, 3000);
    });
  });
} catch (err) {
  const el = document.createElement("p");
  el.className = "error";
  el.textContent = "Options failed to load: " + err.message;
  document.body.appendChild(el);
}

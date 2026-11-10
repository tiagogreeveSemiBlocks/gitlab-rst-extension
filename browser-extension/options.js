const enabledEl = document.getElementById("enabled");
const hostsEl = document.getElementById("hosts");
const saveBtn = document.getElementById("save");
const statusEl = document.getElementById("status");

chrome.storage.sync.get({ enabled: true, hosts: [] }, function (s) {
  enabledEl.checked = s.enabled !== false;
  hostsEl.value = s.hosts.join("\n");
});

saveBtn.addEventListener("click", function () {
  const hosts = hostsEl.value.split(/\s+/).filter(Boolean);
  chrome.storage.sync.set({ enabled: enabledEl.checked, hosts: hosts }, function () {
    statusEl.textContent = "Saved";
  });
});

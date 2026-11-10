// GitLab RST Enhanced - background (Firefox event page).
//
// Robust icon-click fallback: Firefox MV3 uses "action" since version
// 121 and "browser_action" before that. Register the open-options
// listener on whichever exists. If a default_popup attaches, the
// onClicked event never fires, so this is harmless on every version.

const api = typeof browser !== "undefined" ? browser : chrome;

function openSettings() {
  api.runtime.openOptionsPage();
}

if (api.action && api.action.onClicked) {
  api.action.onClicked.addListener(openSettings);
}
if (api.browserAction && api.browserAction.onClicked) {
  api.browserAction.onClicked.addListener(openSettings);
}

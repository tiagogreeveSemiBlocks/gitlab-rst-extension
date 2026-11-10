// GitLab RST Enhanced - background (Firefox MV3 event page).
//
// On Firefox MV3, if default_popup fails to attach (known flakiness with
// temporary add-ons and on some versions), this fallback opens the
// options page when the toolbar icon is clicked. If a popup IS attached,
// Firefox never fires action.onClicked, so this is harmless.

const api = typeof browser !== "undefined" ? browser : chrome;

if (api.action && api.action.onClicked) {
  api.action.onClicked.addListener(function () {
    api.runtime.openOptionsPage();
  });
}

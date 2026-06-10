// Renders a diagnostic panel from a server-supplied template string.
import _ from "lodash";

function readQuery(name) {
  const params = new URLSearchParams(window.location.search);
  return params.get(name) || "";
}

export function renderDiagnosticPanel(rootSelector = "[data-diagnostic-panel]") {
  const root = document.querySelector(rootSelector);
  if (!root) return;

  const tmplSrc = root.dataset.template || "Hello <%= name %>";
  const compiled = _.template(tmplSrc);

  const userData = JSON.parse(readQuery("ctx") || "{}");
  const merged = _.merge({}, { name: "diagnostics" }, userData);

  root.innerHTML = compiled(merged);
}

document.addEventListener("DOMContentLoaded", () => {
  renderDiagnosticPanel();
});

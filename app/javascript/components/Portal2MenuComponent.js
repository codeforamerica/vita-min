export default function Portal2MenuComponent() {
    const menu = document.querySelector('[data-component="Portal2Menu"]');
    const trigger = document.querySelector('[data-component="Portal2MenuTrigger"]');
    const closer = document.querySelector('[data-component="Portal2MenuCloser"]');
    const overlay = document.querySelector('[data-component="Portal2MenuOverlay"]');

    if (!menu || !trigger) return;

    const toggles = [menu, trigger, closer, overlay];
    const open = () => {
        toggles.forEach((el) => el && el.classList.add("open"));
        trigger.setAttribute("aria-expanded", "true");
        sendMixpanelEvent("Portal Menu Opened");
    };
    const close = () => {
        toggles.forEach((el) => el && el.classList.remove("open"));
        trigger.setAttribute("aria-expanded", "false");
    };

    trigger.addEventListener("click", open);
    if (closer) closer.addEventListener("click", close);
    if (overlay) overlay.addEventListener("click", close);

    menu.querySelectorAll("[data-portal2-menu-item]").forEach((link) => {
        link.addEventListener("click", () => {
            sendMixpanelEvent("Portal Menu Clicked", { menu_click: link.dataset.portal2MenuItem });
        });
    });
}

function sendMixpanelEvent(eventName, data = {}) {
    const pageData = document.querySelector("#mixpanelData")?.dataset;
    if (!pageData || !pageData.sendMixpanelBeacon) return;

    const csrfParam = document.querySelector("meta[name=csrf-param]")?.content;
    const csrfToken = document.querySelector("meta[name=csrf-token]")?.content;
    if (csrfParam === undefined || csrfToken === undefined) return;

    const eventData = new FormData();
    eventData.append("event[event_name]", eventName);
    eventData.append("event[controller_action]", pageData.controllerAction);
    eventData.append("event[full_path]", pageData.fullPath);
    Object.keys(data).forEach((key) => {
        eventData.append("event[data][" + key + "]", data[key]);
    });
    eventData.append(csrfParam, csrfToken);

    navigator.sendBeacon("/ajax_mixpanel_events", eventData);
}

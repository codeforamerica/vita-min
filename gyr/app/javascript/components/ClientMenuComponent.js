export default function ClientMenuComponent() {
    const menu = document.querySelector('[data-component="ClientMenuComponent"]');
    const trigger = document.querySelector('[data-component="ClientMenuTrigger"]');
    const closer = document.querySelector('[data-component="ClientMenuCloser"]')
    const overlay = document.querySelector('[data-component="ClientMenuOverlay"]')
    toggleMenu(menu, trigger, closer, overlay);
}

function toggleMenu(menu, trigger, closer, overlay) {
    if (trigger) {
        trigger.addEventListener("click", () => {
            menu.classList.add("open");
            trigger.classList.add("open");
            overlay.classList.add("open");
            closer.classList.add("open");
        });
    }

    if (closer) {
        closer.addEventListener("click", () => {
            menu.classList.remove("open");
            closer.classList.remove("open");
            trigger.classList.remove("open");
            overlay.classList.remove("open");
        });
    }
}

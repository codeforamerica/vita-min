export default function MainMenuComponent() {
    const mainMenu = document.querySelector('[data-component="MainMenuComponent"]');
    highlightSelectedPageNavigation(mainMenu);
    toggleSidebarExpandCollapse(mainMenu);
}

function highlightSelectedPageNavigation(mainMenu) {
    mainMenu.querySelectorAll('.menu-item').forEach((item) => {
        if (item.href === window.location.href) {
            item.classList.toggle('selected');
        }
    });
}

function toggleSidebarExpandCollapse(mainMenu) {
    mainMenu.querySelector('.toggle').addEventListener("click", () => {
        const classes = mainMenu.classList;
        classes.toggle("collapsed");

        if (classes.contains("collapsed")) {
            document.cookie = "sidebar=collapsed";
        } else {
            document.cookie = "sidebar=";
        }
    });
}

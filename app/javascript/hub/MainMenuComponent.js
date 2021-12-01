export default function MainMenuComponent() {
    const mainMenu = document.querySelector('[data-component="MainMenuComponent"]');
    highlightSelectedPageNavigation(mainMenu);
    setSidebarExpandCollapse(mainMenu);
}

function highlightSelectedPageNavigation(mainMenu) {
    mainMenu.querySelectorAll('.menu-item').forEach((item) => {
        if (item.href === window.location.href) {
            item.classList.toggle('selected');
        }
    });
}

function setSidebarExpandCollapse(mainMenu) {
    mainMenu.querySelector('.toggle').addEventListener("click", () => {
        const classes = mainMenu.classList;
        classes.toggle("expanded");
        classes.toggle("collapsed");
    });
}

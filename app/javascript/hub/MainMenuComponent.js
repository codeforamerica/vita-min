export default function MainMenuComponent() {
    const mainMenu = document.querySelector('[data-component="MainMenuComponent"]')
    mainMenu.querySelectorAll('.menu-item').forEach((item) => {
        if (item.href === window.location.href) {
            item.classList.toggle('selected');
        }
    });
}

export default function MainMenuComponent() {
    document.querySelectorAll('[data-component="MainMenuComponent"]').forEach((element) => {
        element.querySelector(".toggle").addEventListener("click", () => {
            const classes = element.classList;
            classes.toggle("expanded")
            classes.toggle("collapsed")
        });
    });
}

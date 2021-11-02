export function initMainMenu () {
    document.querySelector('.main-menu .toggle').addEventListener("click", () => {
        let classes = document.querySelector('.main-menu').classList
        if (document.querySelector('.main-menu.expanded')) {
            classes.remove("expanded")
            classes.add("collapsed")
        } else {
            classes.remove("collapsed")
            classes.add("expanded")
        }
    });
}
import MainMenuComponent from "../../../../app/javascript/hub/MainMenuComponent";
const fs = require("fs");
const path = require("path");

const TEMPLATE = fs.readFileSync(path.join(__dirname, "/template.html"));

describe("toggleSidebarExpandCollapse", () => {
  const { body } = document;
  let mainMenu;
  let toggle;

  beforeEach(() => {
    body.innerHTML = TEMPLATE;
    MainMenuComponent();
    mainMenu = body.querySelector('[data-component="MainMenuComponent"]');
    toggle = mainMenu.querySelector('.toggle');
  });

  it('starts with an expanded state', () => {
    expect(mainMenu.getAttribute("class")).toEqual("main-menu expanded");
  });

  it('toggles the classes on the main menu when the toggle is clicked', () => {
    toggle.click();
    expect(mainMenu.getAttribute("class")).toEqual("main-menu collapsed");
  });

  it('toggles the cookie to indicate it is collapsed', () => {
    toggle.click();
    expect(mainMenu.getAttribute("class")).toEqual("main-menu collapsed");

    expect(document.cookie).toContain("sidebar=collapsed");

    toggle.click();
    expect(mainMenu.getAttribute("class")).toEqual("main-menu expanded");
    expect(document.cookie).not.toContain("sidebar=collapsed");
  });
})

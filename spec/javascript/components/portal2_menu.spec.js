import Portal2MenuComponent from "components/Portal2MenuComponent";

describe("Portal2MenuComponent", () => {
  beforeEach(() => {
    document.body.innerHTML = `
      <meta name="csrf-param" content="iamaparam" />
      <meta name="csrf-token" content="iamatoken" />
      <meta id="mixpanelData" data-controller-action="portal/portal2#home"
            data-full-path="/en/portal/portal2" data-send-mixpanel-beacon="true" />
      <button data-component="Portal2MenuTrigger" aria-expanded="false">Menu</button>
      <button data-component="Portal2MenuCloser">Close</button>
      <div data-component="Portal2MenuOverlay"></div>
      <nav data-component="Portal2Menu">
        <a href="/en/portal/portal2" data-portal2-menu-item="home">Home</a>
        <a href="/en/portal/messages/new" data-portal2-menu-item="messages">Messages</a>
        <a href="/en/portal/upload-documents/overview" data-portal2-menu-item="documents">Documents</a>
        <a href="/en/portal/tax-returns" data-portal2-menu-item="tax returns">Tax returns</a>
        <a href="/en/portal/settings" data-portal2-menu-item="settings">Account info</a>
      </nav>
    `;
    navigator.sendBeacon = jest.fn();
    Portal2MenuComponent();
  });

  const menu = () => document.querySelector('[data-component="Portal2Menu"]');
  const trigger = () => document.querySelector('[data-component="Portal2MenuTrigger"]');
  const closer = () => document.querySelector('[data-component="Portal2MenuCloser"]');
  const overlay = () => document.querySelector('[data-component="Portal2MenuOverlay"]');

  const lastEvent = () => {
    const calls = navigator.sendBeacon.mock.calls;
    return calls[calls.length - 1][1];
  };

  test("opens from the Menu button", () => {
    expect(menu().classList.contains("open")).toBe(false);

    trigger().click();

    [menu(), trigger(), closer(), overlay()].forEach((el) => {
      expect(el.classList.contains("open")).toBe(true);
    });
    expect(trigger().getAttribute("aria-expanded")).toEqual("true");
  });

  test("closes from the X button", () => {
    trigger().click();
    closer().click();

    [menu(), trigger(), closer(), overlay()].forEach((el) => {
      expect(el.classList.contains("open")).toBe(false);
    });
    expect(trigger().getAttribute("aria-expanded")).toEqual("false");
  });

  test("closes when the overlay is clicked", () => {
    trigger().click();
    overlay().click();

    expect(menu().classList.contains("open")).toBe(false);
  });

  test("sends Portal Menu Opened when the menu opens", () => {
    trigger().click();

    expect(navigator.sendBeacon).toBeCalled();
    expect(lastEvent().get("event[event_name]")).toEqual("Portal Menu Opened");
    expect(lastEvent().get("event[controller_action]")).toEqual("portal/portal2#home");
    expect(lastEvent().get("event[full_path]")).toEqual("/en/portal/portal2");
  });

  test("sends Portal Menu Clicked with the menu_click property for each item", () => {
    ["home", "messages", "documents", "tax returns", "settings"].forEach((item) => {
      document.querySelector(`[data-portal2-menu-item="${item}"]`).click();

      expect(lastEvent().get("event[event_name]")).toEqual("Portal Menu Clicked");
      expect(lastEvent().get("event[data][menu_click]")).toEqual(item);
    });
  });

  test("does not send events when the beacon is disabled", () => {
    document.querySelector("#mixpanelData").removeAttribute("data-send-mixpanel-beacon");

    trigger().click();

    expect(navigator.sendBeacon).not.toBeCalled();
  });

  test("does not send events when csrf info is missing", () => {
    document.querySelector("meta[name=csrf-param]").remove();

    trigger().click();

    expect(navigator.sendBeacon).not.toBeCalled();
  });
});

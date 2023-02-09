import AjaxMixpanelEvents from "lib/mixpanel_event_tracking";

describe('MixpanelEventTracking', () => {
    beforeEach(() => {
        document.body.innerHTML = `
          <meta id="mixpanelData" data-controller-action="fake#action" 
                data-full-path="/fake/path" data-send-mixpanel-beacon="true" />
          <a data-track-click="fake-event" href="/en/welcome">A Link</a>
        `;
        navigator.sendBeacon = jest.fn();
        window.Rails = {
            csrfToken: () => {},
            csrfParam: () => {}
        }
    });


    describe('tracked clicks via [data-track-click]', () => {
        test('adds a click event that emits the beacon', () => {
            AjaxMixpanelEvents.init();
            document.querySelector("a").click();
            expect(navigator.sendBeacon).toBeCalled();
        });
    });
});
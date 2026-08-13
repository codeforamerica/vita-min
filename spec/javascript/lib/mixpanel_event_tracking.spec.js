import MixpanelEventTracking from "lib/mixpanel_event_tracking";

describe('MixpanelEventTracking', () => {
  beforeEach(() => {
    document.body.innerHTML = `
          <meta name="csrf-param">iamaparam</meta>
          <meta name="csrf-token">iamatoken</meta>
          <meta id="mixpanelData" data-controller-action="fake#action" 
                data-full-path="/fake/path" data-send-mixpanel-beacon="true" />
          <a data-track-click="fake-event" data-track-attribute-is-welcoming="yup" href="/en/welcome">A Link</a>
          <a id="outboundLink" href="https://example.com/">Example link to somewhere radical and new</a>
          <a id="nestedLink" data-track-click="download-event" data-track-attribute-return-status="review_signature_requested" href="/en/documents/1">
            <span id="nestedSpan">Download your papers</span><i id="nestedIcon"></i>
          </a>
        `;
    navigator.sendBeacon = jest.fn();
  });

  describe('tracked clicks via [data-track-click]', () => {
    test('does not track clicks when csrf info is missing', () => {
      document.querySelector('meta[name=csrf-param]').remove();
      MixpanelEventTracking.listenForTrackedClicks();
      document.querySelector("a").click();
      expect(navigator.sendBeacon).not.toBeCalled();
    });

    test('sends tracked click event to mixpanel', () => {
      MixpanelEventTracking.listenForTrackedClicks();
      document.querySelector("a").click();
      expect(navigator.sendBeacon).toBeCalled();
      expect(navigator.sendBeacon.mock.calls[0][1].get("event[data][href]")).toBeNull();
      expect(navigator.sendBeacon.mock.calls[0][1].get("event[data][is_welcoming]")).toEqual("yup");
    });

    test('reads the tracked link, not the child that was clicked', () => {
      MixpanelEventTracking.listenForTrackedClicks();
      document.querySelector("#nestedSpan").click();

      expect(navigator.sendBeacon).toBeCalled();
      const eventData = navigator.sendBeacon.mock.calls[0][1];
      expect(eventData.get("event[event_name]")).toEqual("click_download-event");
      expect(eventData.get("event[data][return_status]")).toEqual("review_signature_requested");
    });

    test('tracks clicks that land on a nested icon with no text of its own', () => {
      MixpanelEventTracking.listenForTrackedClicks();
      document.querySelector("#nestedIcon").click();

      expect(navigator.sendBeacon).toBeCalled();
      expect(navigator.sendBeacon.mock.calls[0][1].get("event[event_name]")).toEqual("click_download-event");
    });
  });

  describe('outbound links', () => {
    test('send mixpanel event', () => {
      MixpanelEventTracking.addClickTrackingToOutboundLinks();
      const outboundLink = document.querySelector("#outboundLink");
      const dataset = outboundLink.dataset;
      expect(dataset.trackClick).toEqual("outbound_link");
      expect(dataset.trackClickHref).toEqual("true");

      MixpanelEventTracking.listenForTrackedClicks();
      outboundLink.click();
      expect(navigator.sendBeacon).toBeCalled();
      expect(navigator.sendBeacon.mock.calls[0][1].get("event[data][href]")).toEqual("https://example.com/")
    })
  });
});

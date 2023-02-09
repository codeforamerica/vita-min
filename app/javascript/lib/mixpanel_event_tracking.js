import "../vendor/navigator.sendbeacon.min.js";


const MixpanelEventTracking = (function () {
    const addClickTrackingToOutboundLinks = function () {
      const links = document.querySelectorAll("a[href]:not([href^='/']):not([href^='#']):not([href^='" + location.protocol + "//" + location.host + "'])");
      links.forEach((link) => {
        link.dataset.trackClick = "outbound_link";
        link.dataset.trackClickHref = "true";
      })
    }
    const listenForTrackedClicks = function () {
      document.querySelectorAll("a[data-track-click]").forEach((link) => {
        link.addEventListener("click", function (e, options) {
          const pageData = document.querySelector("#mixpanelData").dataset;
          const clickedElement = e.target;
          const eventName = "click_" + clickedElement.dataset.trackClick;

          const eventData = new FormData();

          for (const key in clickedElement.dataset) {
            const attributePrefix = "trackAttribute";

            if (key.startsWith(attributePrefix)) {
              const snakeCasedPropertyName = key.substring(attributePrefix.length)
                .split(/(?=[A-Z])/).join('_').toLowerCase();
              eventData.append("event[data][" + snakeCasedPropertyName + "]", clickedElement.dataset[key]);
            }
          }

          eventData.append("event[event_name]", eventName);
          eventData.append("event[controller_action]", pageData.controllerAction);
          eventData.append("event[full_path]", pageData.fullPath);
          eventData.append("event[data][call_to_action]", (clickedElement.innerText || "").trim());
          if (clickedElement.dataset.trackClickHref === "true") {
            eventData.append("event[data][href]", clickedElement.href);
          }
          eventData.append(Rails.csrfParam(), Rails.csrfToken());
          if (pageData.sendMixpanelBeacon) {
            navigator.sendBeacon("/ajax_mixpanel_events", eventData);
          }
        });
      })
    };

    return {
      listenForTrackedClicks,
      addClickTrackingToOutboundLinks
    }
  }
)
();

export default MixpanelEventTracking;

import "../vendor/navigator.sendbeacon.min.js";

const AjaxMixpanelEvents = (function () {
  const init = function () {
    $(document).ready(function() {
      $("[data-track-click]").on("click", function (e, options) {
        const pageData = document.querySelector("#mixpanelData").dataset;
        const clickedElement = $(e.target).closest("a");
        const dataAttributes = clickedElement.data();
        const elementText = clickedElement.text().trim();
        const eventName = "click_" + dataAttributes["trackClick"];

        const eventData = new FormData();

        $.each(dataAttributes, function (key, value) {
          const attributePrefix = "trackAttribute";
          if (key.indexOf(attributePrefix) === 0) {
            const propertyKey = key.substring(attributePrefix.length).toLowerCase();
            eventData.append("event[data]["+propertyKey+"]", value);
          }
        });

        eventData.append("event[event_name]", eventName);
        eventData.append("event[controller_action]", pageData.controllerAction);
        eventData.append("event[full_path]", pageData.fullPath);
        eventData.append("event[data][call_to_action]", elementText);
        eventData.append(Rails.csrfParam(), Rails.csrfToken());
        if (pageData.sendMixpanelBeacon) {
          navigator.sendBeacon("/ajax_mixpanel_events", eventData);
        }
      });
    });
  };

  return {
    init: init
  }
})();

export default AjaxMixpanelEvents;

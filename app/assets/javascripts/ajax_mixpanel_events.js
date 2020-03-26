//= require vendor/navigator.sendbeacon.min

var ajaxMixpanelEvents = (function() {
  var init = function() {
    $("[data-track-click]").on("click", function (e, options) {
      var clickedElement = $(e.target).closest("a");
      var elementText = clickedElement.text().trim();
      var eventName = "click_" + clickedElement.attr("data-track-click");

      var eventData = new FormData();
      eventData.append("event[event_name]", eventName);
      eventData.append("event[controller_action]", window.mixpanelData.controller_action);
      eventData.append("event[full_path]", window.mixpanelData.full_path);
      eventData.append("event[data][call_to_action]", elementText);
      eventData.append(Rails.csrfParam(), Rails.csrfToken());

      navigator.sendBeacon("/ajax_mixpanel_events", eventData);
    });
  };

  return {
    init: init
  }
})();

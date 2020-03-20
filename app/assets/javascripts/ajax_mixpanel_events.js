var ajaxMixpanelEvents = (function() {
  var init = function() {
    $("[data-track-click]").on("click", function (e, options) {
      options = options || {};
      if (options.trackedEvent === true) {
        return;
      }

      e.preventDefault();
      e.stopPropagation();

      var clickedElement = $(e.target);
      var elementText = clickedElement.text().trim();
      var eventName = "click_" + clickedElement.attr("data-track-click");
      var eventData = {
        event_name: eventName,
        controller_action: window.mixpanelData.controller_action,
        full_path: window.mixpanelData.full_path,
        data: {
          call_to_action: elementText,
        }
      };

      $.ajax({
        type: "POST",
        url: "/ajax_mixpanel_events",
        data: eventData,
      })
      .then(function() { clickedElement.trigger("click", {trackedEvent: true}) })
      .fail(function() { clickedElement.trigger("click", {trackedEvent: true}) });
    });
  };

  return {
    init: init
  }
})();

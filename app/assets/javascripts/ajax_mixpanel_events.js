var ajaxMixpanelEvents = (function() {
  var init = function() {
    $("[data-track-click]").on("click", function (e, options = {}) {
      if (options.trackedEvent === true) {
        return;
      }

      e.preventDefault();
      e.stopPropagation();

      var clickedElement = $(e.target);
      var eventData = {
        event_name: "clicked_link",
        controller_action: window.mixpanelData.controller_action,
        full_path: window.mixpanelData.full_path,
        data: {
          link_text: clickedElement.text().trim(),
        }
      };

      $.ajax({
        type: "POST",
        url: "/ajax_mixpanel_events",
        timeout: 200,
        data: eventData,
      })
      .then(() => clickedElement.trigger("click", {trackedEvent: true}))
      .fail(() => clickedElement.trigger("click", {trackedEvent: true}));
    });
  };

  return {
    init: init
  }
})();
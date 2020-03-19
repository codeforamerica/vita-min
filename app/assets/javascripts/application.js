// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require_tree .
//= require cfa_styleguide_main

var immediateUpload = (function() {
  var uploader = function() {
    var fileUploadForm = $('form#file-upload-form')
    var fileInputElements = fileUploadForm.find('input[type="file"][data-upload-immediately]');

    // hide the submit button fallback
    fileUploadForm.find("button[type=submit]").hide();
    // show the label button
    fileUploadForm.find('label.js-only').show();

    // submit the form immediately after a file is uploaded
    fileInputElements.change(function(_event) {
      fileUploadForm.submit();
    });
  };

  return {
    init: uploader
  }
})();

$(document).ready(function() {
  ajaxMixpanelEvents.init();
});
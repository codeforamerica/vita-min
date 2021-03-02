export var documentSubmittingIndicator = (function() {
    var dsi = function() {
        var fileUploadForm = $('form#file-upload-form');
        var fileInputElements = fileUploadForm.find('input[type="file"][data-upload-immediately]');

        fileInputElements.change(function(_event) {
            document.body.classList.add('submitting');
        });
    };

    return {
        init: dsi
    }
})();

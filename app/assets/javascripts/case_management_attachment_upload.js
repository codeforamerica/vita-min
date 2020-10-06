document.addEventListener("DOMContentLoaded", function(){
    var imageUploader = document.querySelector('#attachment-upload');
    var customPreviewDiv = document.querySelector('#attachment-custom-preview');
    var previewImageDefault = document.querySelector('#attachment-image-preview-default');

    var clearAttachments = document.querySelector('#attachment-image-clear');
    previewImageDefault.hidden = true;

    clearAttachments.addEventListener('click', function(e)  {
        e.preventDefault();
        imageUploader.value = '';
        customPreviewDiv.innerHTML = '';
        previewImageDefault.hidden = true;
        clearAttachments.hidden = true;
    })

    imageUploader.addEventListener('change', function (event) {
        var files   = this.files;

        function readAndPreview(file) {
            // Show preview if can for filetype
            if ( /\.(jpe?g|png|gif)$/i.test(file.name) ) {

                var reader = new FileReader();

                reader.addEventListener("load", function () {
                    var image = new Image();
                    image.height = 100;
                    image.title = file.name;
                    image.src = this.result;
                    customPreviewDiv.appendChild(image);
                }, false);
                reader.readAsDataURL(file);
                previewImageDefault.hidden = true;

            } else {
                customPreviewDiv.innerHTML = '';
                previewImageDefault.hidden = false;
            }
        }

        if (files) {
            [].forEach.call(files, readAndPreview);
            clearAttachments.hidden = false;
        }
    });
});


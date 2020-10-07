document.addEventListener("DOMContentLoaded", function(){
    if (document.querySelector(".attachment-uploader")) {
        var imageUploader = document.querySelector('input.attachment-upload');
        var previewImage = document.querySelector('#attachment-image-preview');
        var previewImageDefaultSrc = previewImage.src
        var clearAttachmentsButton = document.querySelector('button#attachment-image-clear');
        // Start with preview image hidden
        previewImage.hidden = true;

        clearAttachmentsButton.addEventListener('click', function(e)  {
            e.preventDefault();
            imageUploader.value = '';
            previewImage.hidden = true;
            clearAttachmentsButton.hidden = true;
        });

        imageUploader.addEventListener('change', function (event) {
            var files   = this.files;
            function readAndPreview(file) {
                // Show preview if can for filetype
                if ( /\.(jpe?g|png|gif)$/i.test(file.name) ) {
                    var reader = new FileReader();
                    reader.addEventListener("load", function () {
                        previewImage.title = file.name;
                        previewImage.src = this.result;
                    }, false);
                    reader.readAsDataURL(file);

                } else {
                    previewImage.src = previewImageDefaultSrc;
                }
                previewImage.hidden = false;
            }

            if (files) {
                [].forEach.call(files, readAndPreview);
                clearAttachmentsButton.hidden = false;
            }
        });
    }
});


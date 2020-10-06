document.addEventListener("DOMContentLoaded", function(){
    var imageUploader = document.querySelector('#attachment-upload');
    var preview = document.querySelector('#attachment-image-preview');
    var clearAttachments = document.querySelector('#attachment-image-clear');

    clearAttachments.addEventListener('click', function(e)  {
        e.preventDefault();
        imageUploader.value = '';
        preview.innerHTML = '';
        clearAttachments.hidden = true;
    })

    imageUploader.addEventListener('change', function (event) {
        var files   = this.files;

        function readAndPreview(file) {

            // Make sure `file.name` matches our extensions criteria
            console.log(file.name)
            if ( /\.(jpe?g|png|gif)$/i.test(file.name) ) {
                var reader = new FileReader();

                reader.addEventListener("load", function () {
                    var image = new Image();
                    image.height = 100;
                    image.title = file.name;
                    image.src = this.result;
                    preview.appendChild( image );
                }, false);

                reader.readAsDataURL(file);
            } else {
                var image = new Image();
                image.height = 100;
                image.title = file.name;
                image.src = "app/assets/images/file-icon.svg";
                preview.appendChild(image);
            }

        }

        if (files) {
            preview.innerHTML = '';
            [].forEach.call(files, readAndPreview);
            clearAttachments.hidden = false;
        }
    });
});


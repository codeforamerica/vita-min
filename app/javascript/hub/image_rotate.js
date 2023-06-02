export default function imageRotate() {
    const rotateButton = document.getElementById("rotate-button");
    let rotationAngle = document.getElementById("rotation-angle");

    if(!rotateButton) {
        return
    }

    rotateButton.addEventListener("click", function(e) {
        e.preventDefault();
        // Get the image element
        const image = document.getElementById("image");
        const container = document.getElementById("image-container");

        // Increment the rotation angle by 90 degrees
        let rotation = parseFloat(image.dataset.rotation) || 0;
        rotation += 90;
        rotationAngle.value = rotation;

        function fitImageForRotation(image, container) {
            if (image.naturalWidth < image.naturalHeight) {
                let newHeight = container.offsetWidth < image.naturalHeight ? `${container.offsetWidth}px` : 'auto';
                image.style.width = `auto`;
                image.style.height = newHeight;
            } else {
                let newWidth = container.offsetHeight < image.naturalWidth ? `${container.offsetHeight}px` : 'auto';
                image.style.width = newWidth;
                image.style.height = `auto`;
            }
        }

        // // Apply the rotation using CSS transform
        if ((rotation % 360) == 90) {
            // For a 90 degree rotation, choose top left rotation corner, push left by the image's height (which becomes its width after rotation), rotate
            fitImageForRotation(image, container);
            image.style.transform = `translateX(${image.height}px) rotate(${rotation}deg)`;
            image.style.transformOrigin = `top left`;
        } else if ((rotation % 360) == 270) {
            // For a 270 degree rotation, choose top left rotation corner, push down by the image's width (which becomes its height after rotation), rotate
            fitImageForRotation(image, container);
            image.style.transform = `translateY(${image.width}px) rotate(${rotation}deg)`;
            image.style.transformOrigin = `top left`;
        } else {
            image.style.transform = `rotate(${rotation}deg)`;
            image.style.transformOrigin = `center`;
            image.style.width = 'auto';
            image.style.height = 'auto';
        }

        // Update the rotation angle in the dataset attribute
        image.dataset.rotation = rotation;
    });
};
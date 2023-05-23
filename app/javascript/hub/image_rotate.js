// import $ from 'jquery';
//
// $(document).ready(function() {
//     $('#rotate-button').click(function(e) {
//         e.preventDefault();
//
//         // Get the image element
//         let image = $(this).data('image');
//
//         // Increment the rotation angle by 90 degrees
//         let rotation = (parseFloat(image.dataset.rotation) || 0) + 90;
//
//         // Apply the rotation using CSS transform
//         image.style.transform = 'rotate(' + rotation + 'deg)';
//
//         // Update the rotation angle in the dataset attribute
//         image.dataset.rotation = rotation;
//     });
// });
import adjustImageSize from "./adjust-image-size";

export default function imageRotate() {
    const rotateButton = document.getElementById("rotate-button");

    rotateButton.addEventListener("click", function(e) {
        e.preventDefault();
        // Get the image element
        const image = document.getElementById("image");
        const container = document.getElementById("image-container");
        console.log(container.offsetHeight);

        // Increment the rotation angle by 90 degrees
        let rotation = parseFloat(image.dataset.rotation) || 0;
        rotation += 90;

        image.style.transform = `rotate(${rotation}deg)`;

        const containerOffset = 12;

        // // Apply the rotation using CSS transform
        if ((rotation % 360) == 90) {
            // For a 90 degree rotation, choose top left rotation corner, push left by the image's height (which becomes its width after rotation), rotate
            const translateX = Math.round(container.offsetHeight / 2) + containerOffset;
            image.style.transform = `translateX(${translateX}px) rotate(${rotation}deg)`;
            image.style.transformOrigin = `top left`;
            image.style.width = `${container.offsetHeight}px`;
            image.style.height = 'auto';
        } else if ((rotation % 360) == 270) {
            // For a 270 degree rotation, choose top left rotation corner, push left by the image's height (which becomes its width after rotation), push down by the images width (which will become its height), rotate
            image.style.transform = `translateY(${container.offsetHeight}px) rotate(${rotation}deg)`;
            image.style.transformOrigin = `top left`;
            image.style.width = `${container.offsetHeight}px`;
        } else {
            image.style.transform = `rotate(${rotation}deg)`;
            image.style.transformOrigin = `center`;
            image.style.width = '100%';
        }

        // Update the rotation angle in the dataset attribute
        image.dataset.rotation = rotation;

        adjustImageSize();
    });
};
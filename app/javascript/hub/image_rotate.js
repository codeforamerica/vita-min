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

        // Increment the rotation angle by 90 degrees
        let rotation = parseFloat(image.dataset.rotation) || 0;
        rotation += 90;

        // Apply the rotation using CSS transform
        image.style.transform = `rotate(${rotation}deg)`;

        // Update the rotation angle in the dataset attribute
        image.dataset.rotation = rotation;

        adjustImageSize();
    });
};

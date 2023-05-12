export default function adjustImageSize() {
    console.log("adjust!!!!")
    const image = document.getElementById("image");
    const container = document.getElementById("image-container");

    const containerWidth = container.offsetWidth;
    const containerHeight = container.offsetHeight;

    const imageRatio = image.naturalWidth / image.naturalHeight;
    const containerRatio = containerWidth / containerHeight;

    if (imageRatio > containerRatio) {
        image.style.width = "100%";
        image.style.height = "auto";
    } else {
        image.style.width = "auto";
        image.style.height = "100%";
    }
};

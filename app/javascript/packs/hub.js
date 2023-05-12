// See `app/javascript/hub/README.md`
import MainMenuComponent from "../hub/MainMenuComponent";
import imageRotate from "../hub/image_rotate";
import adjustImageSize from "../hub/adjust-image-size";

window.addEventListener("load", function() {
  MainMenuComponent();
  imageRotate();
  adjustImageSize()
})

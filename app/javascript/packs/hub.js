// See `app/javascript/hub/README.md`
import MainMenuComponent from "../hub/MainMenuComponent";
import imageRotate from "../hub/image_rotate";
import feedback from "../hub/feedback";

window.addEventListener("load", function() {
  MainMenuComponent();
  imageRotate();
  feedback();
})

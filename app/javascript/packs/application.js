import "core-js/stable"
import "regenerator-runtime/runtime"
import RailsUJS from "@rails/ujs";
import * as ActiveStorage from "@rails/activestorage";
import "trix"
import "@rails/actiontext"
import "@yaireo/tagify/dist/tagify.css";
import "jquery-ui";
import Listeners from "../listeners";

// Setting globally isn't very webpack-y,
// but we have things (views, test runner) in the app that require jquery on the window object.
window.jQuery = $;
window.$ = $;

RailsUJS.start();
ActiveStorage.start();

import "../lib/honeycrisp";


Listeners.init();

import jMaskGlobals from "jquery-mask-plugin";
jMaskGlobals.watchDataMask = true;

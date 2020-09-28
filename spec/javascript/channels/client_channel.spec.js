import {callback} from "channels/client_channel";
import {describe} from "@jest/globals";

describe("Client channel", () => {
    test("updates DOM when receive data", () => {
        document.body.innerHTML = '<div id="contact-history">old</div><p>unrelated</p>';

        callback.received("new<b>contact history</b>");
        expect(document.body.innerHTML).toEqual(
        '<div id="contact-history">new<b>contact history</b></div><p>unrelated</p>'
        );
    });
});

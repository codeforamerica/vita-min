import {callback, getChannelName} from "channels/client_channel";
import {describe} from "@jest/globals";
import consumer from "../../../app/javascript/channels/consumer";

describe("Client channel", () => {
    test("can add an element to the page", () => {
        document.body.innerHTML = '<div class="message-list">old<p>unrelated</p></div>';

        callback.received(['<p id="#new-message">a message came in</p>']);
        expect(document.body.innerHTML).toEqual(
            '<div class="message-list">old<p>unrelated</p><p id="#new-message">a message came in</p></div>'
        );
    });

    test("can create a client channel based on id in url", () => {
        expect(getChannelName("http://www.example.com/en/case_management/clients/14/messages")).toEqual(
            {channel: "ClientChannel", id: "14"}
        );
    })
});
import {callback, getChannelName} from "channels/client_channel";

describe("Client channel", () => {
    test("can add an element to the page", () => {
        document.body.innerHTML = '<div class="message-list">old<p>unrelated</p></div>';

        callback.received(['<p id="#new-message">a message came in</p>']);
        expect(document.body.innerHTML).toEqual(
            '<div class="message-list">old<p>unrelated</p><p id="#new-message">a message came in</p></div>'
        );
    });

    test("can create a client channel based on id in url", () => {
        window.clientId = 234219;

        expect(getChannelName()).toEqual({channel: "ClientChannel", id: 234219});
    })
});
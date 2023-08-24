import {callback, getChannelName} from "channels/client_channel";

describe("callback.received", () => {
    test("can add an element to the page", () => {
        document.body.innerHTML = '<ul data-js="messages-pub-sub"><li>old</li><li>unrelated</li></ul>';

        callback.received(['<li id="#new-message">a message came in</li>']);
        expect(document.body.innerHTML).toEqual(
            '<ul data-js="messages-pub-sub"><li>old</li><li>unrelated</li><li id="#new-message">a message came in</li></ul>'
        );
    });
});

describe("getChannelName", () => {
    test("can create a client channel based on id in url", () => {
        document.body.innerHTML = '<ul data-js="messages-pub-sub" data-client-id="234219"></ul>';

        expect(getChannelName()).toEqual({channel: "ClientChannel", id: "234219"});
    })
});
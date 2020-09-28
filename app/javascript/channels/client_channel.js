import consumer from "./consumer"

const channelName = {
    channel: "ClientChannel",
    id: "1" // TODO: Grab the client ID out of e.g. the URL
};

export const callback = {
    connected() {
        console.log("connected, wow! Here is some debug logging.");
        console.log(consumer);
        console.log(consumer.subscriptions);
    },
    received(data) {
        document.querySelector('#contact-history').innerHTML = data;
        document.querySelector('#contact-history').focus();
    }
};

consumer.subscriptions.create(channelName, callback);

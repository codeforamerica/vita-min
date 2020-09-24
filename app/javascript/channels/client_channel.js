import consumer from "./consumer"

const channelName = {
    channel: "ClientChannel",
    room: "BestClient"
};

const callback = {
    received(data) {
        console.log("received :" + data);
    }
};

consumer.subscriptions.create(channelName, callback);
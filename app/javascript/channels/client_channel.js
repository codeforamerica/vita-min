export function getChannelName(url) {
  return { channel: "ClientChannel", id: url.match(/\/clients\/(\d*)\/messages/)[1] }
};

export const callback = {
  connected() {
    console.log("We're connected!")
  },

  disconnected() {
    console.log("We're disconnected!")
  },

  received(data) {
    let newContent = data[0];

    document.querySelector(".message-list").innerHTML += newContent;
  }
};

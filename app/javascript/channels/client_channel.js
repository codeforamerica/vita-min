export function getChannelName() {
  return { channel: "ClientChannel", id: window.clientId }
}

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

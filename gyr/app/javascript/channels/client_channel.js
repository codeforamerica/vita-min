export function getChannelName() {
  const messagesList = document.querySelector("ul[data-js='messages-pub-sub']");
  return { channel: "ClientChannel", id: messagesList.dataset.clientId }
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

    document.querySelector("ul[data-js='messages-pub-sub']").innerHTML += newContent;
  }
};

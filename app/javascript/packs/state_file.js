import { createConsumer } from "@rails/actioncable"

const { controllerAction } = document.querySelector("#mixpanelData")?.dataset || {};
if (controllerAction == "StateFile::Questions::WaitingToLoadDataController#edit") {
    let channelName = {
        channel: 'DfDataTransferJobChannel',
    };
    createConsumer().subscriptions.create(channelName, {
        connected() {
            console.log("We're connected!")
            document.querySelector('[data-after-data-transfer-button]').setAttribute('data-subscribed', 'true')
        },

        disconnected() {
            console.log("We're disconnected!")
        },

        received(data) {
            document.querySelector('[data-after-data-transfer-button]').click()
        }
    })
}

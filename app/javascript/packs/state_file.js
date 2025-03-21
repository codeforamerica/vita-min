import { createConsumer } from "@rails/actioncable"

const actionMap = {
  "StateFile::Questions::WaitingToLoadDataController#edit": {
    channelName: { channel: "DfDataTransferJobChannel" },
    channelEvents: {
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
    }
  },
  "StateFile::Questions::SubmissionConfirmationController#edit": {
    channelName: { channel: "StateFileSubmissionPdfStatusChannel" },
    channelEvents: {
      initialized () {
        this.pdfStatus = null
      },

      handleStatusChange () {
        const loadingBlock = document.querySelector('.loading-container')
        const linkBlock = document.querySelector('.download-link-container')
        if (this.pdfStatus === "ready") {
          loadingBlock.style.display = "none"
          linkBlock.style.display = "block"
        } else {
          loadingBlock.style.display = "block"
          linkBlock.style.display = "none"
        }
      },

      connected () {
        this.subscription = this

        setTimeout(() => {
          this.perform("status_update")
        }, 500)

        setTimeout(() => {
          const loadingBlock = document.querySelector('.loading-container')
          const linkBlock = document.querySelector('.download-link-container')
          loadingBlock.style.display = "none"
          linkBlock.style.display = "block"

          this.subscription.unsubscribe()
        }, 15000)
      },

      disconnected () {
        this.pdfStatus = 'disconnected'
      },

      received ({status}) {
        this.pdfStatus = status
        this.handleStatusChange()
      }
    },
  }
}

const { controllerAction } = document.querySelector("#mixpanelData")?.dataset || {};
if (actionMap[controllerAction]) {
  const { channelName, channelEvents } = actionMap[controllerAction]
  createConsumer().subscriptions.create(channelName, channelEvents)
}

if (controllerAction === "StateFile::Questions::SubmissionConfirmationController#edit") {
  window.addEventListener("pageshow", function (event) {
    console.log("pageshow fired", event);
    if (event.persisted) {
      console.log("reloading due to bfcache restore");
      window.location.reload();
    }
  });
}


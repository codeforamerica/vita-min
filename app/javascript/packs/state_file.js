import { createConsumer } from "@rails/actioncable"

const actionMap = {
  "StateFile::Questions::WaitingToLoadDataController#edit": {
    channelName: { channel: "DfDataTransferJobChannel" },
    channelEvents: {
      connected() {
        document.querySelector('[data-after-data-transfer-button]').setAttribute('data-subscribed', 'true')
      },
      received() {
        document.querySelector('[data-after-data-transfer-button]').click()
      }
    }
  },

  "StateFile::Questions::SubmissionConfirmationController#edit": {
    channelName: { channel: "StateFileSubmissionPdfStatusChannel" },
    channelEvents: {
      initialized() {
        this.pdfStatus = null
      },

      toggleLoadingVisibility(status) {
        const loadingBlock = document.querySelector('.loading-container')
        const linkBlock = document.querySelector('.download-link-container')

        const showDownloadLink = status === "ready" || status === "disconnected"

        if (loadingBlock) loadingBlock.style.display = showDownloadLink ? "none" : "block"
        if (linkBlock) linkBlock.style.display = showDownloadLink ? "block" : "none"
      },

      handleStatusChange() {
        this.toggleLoadingVisibility(this.pdfStatus)
      },

      connected() {
        this.subscription = this

        setTimeout(() => {
          this.perform("status_update")
        }, 500)

        setTimeout(() => {
          this.toggleLoadingVisibility("ready")
          this.subscription.unsubscribe()
        }, 15000)
      },

      rejected() {
        this.pdfStatus = 'disconnected'
        this.toggleLoadingVisibility('disconnected')
      },

      disconnected() {
        this.pdfStatus = 'disconnected'
      },

      received({ status }) {
        this.pdfStatus = status
        this.handleStatusChange()
      }
    }
  }
}

const { controllerAction } = document.querySelector("#mixpanelData")?.dataset || {};
if (actionMap[controllerAction]) {
  const { channelName, channelEvents } = actionMap[controllerAction]
  createConsumer().subscriptions.create(channelName, channelEvents)
}
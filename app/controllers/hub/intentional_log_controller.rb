module Hub
  class IntentionalLogController < Hub::BaseController
    before_action :require_engineer
    layout "hub"

    def index
      Rails.logger.info("This an intentional info log line.")
      Rails.logger.warn("This an intentional warning log line.")
      Rails.logger.error("This an intentional error log line.")

      render plain: "Okay!"
    end
  end
end

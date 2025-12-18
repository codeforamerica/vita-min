module StateFile
  module FystSunsetRedirectConcern
    extend ActiveSupport::Concern

    included do
      before_action :sunset_redirect_to_homepage
    end

    private

    def sunset_redirect_to_homepage
      if Flipper.enabled?(:fyst_sunset_pya_live)
        redirect_to root_path
      end
    end
  end
end
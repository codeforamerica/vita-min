module Ctc
  module CanBeginIntakeConcern
    extend ActiveSupport::Concern

    included do
      before_action :check_ctc_intake_cookie
    end

    private

    def check_ctc_intake_cookie
      return unless Rails.env.production?
      return if current_client&.intake&.is_ctc?
      return if ENV['CTC_INTAKE_PUBLIC_ACCESS']

      unless cookies[:ctc_intake_ok]
        raise ActionController::RoutingError.new('Not Found')
      end
    end
  end
end

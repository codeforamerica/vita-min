module Ctc
  module CanBeginIntakeConcern
    extend ActiveSupport::Concern

    included do
      before_action :check_ctc_intake_cookie
    end

    private

    def check_ctc_intake_cookie
      return if open_for_ctc_intake?
      return if current_client&.intake&.is_ctc?

      raise ActionController::RoutingError.new('Not Found')
    end
  end
end

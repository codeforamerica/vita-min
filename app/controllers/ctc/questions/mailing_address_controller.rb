module Ctc
  module Questions
    class MailingAddressController < QuestionsController
      include AuthenticatedCtcClientConcern
      before_action :set_return_location_from_session, only: :edit

      def edit
        if session[:confirm_info_found_address_error]
          @form = initialized_update_form
          @form.valid?
        else
          super
        end
      end

      layout "intake"

      def set_return_location_from_session
        if params[:return_to_confirmation_page]
          session[:return_to_confirmation_page] = true
        end
      end
    end
  end
end
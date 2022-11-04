require 'csv'

module Hub
  class BulkSignupMessagesController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    load_and_authorize_resource
    before_action :set_new_params, only: :new

    layout "hub"

    def new
      @main_heading = "Sending #{@message_type} to #{@signup_selection.id_array.size} signup record(s)"
      @bulk_signup_message = BulkSignupMessage.new
    end

    def create

    end

    private

    def set_new_params
      @message_type =
        case params[:message_type]
        when "email"
          "email"
        when "text_message"
          "text message"
        end
      @signup_selection = SignupSelection.accessible_by(current_ability).find(params[:signup_selection_id]) if params[:signup_selection_id].present?

      if @message_type.nil? || @signup_selection.nil?
        redirect_to Hub::SignupSelectionsController.to_path_helper(action: :index)
      end
    end

    def create_params
      puts params
      params.require(:bulk_signup_message).permit(:signup_selection_id, :message, :message_type)
    end
  end
end

require 'csv'

module Hub
  class BulkSignupMessagesController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    load_and_authorize_resource

    layout "hub"

    def new
      set_instance_variables(params)
      @bulk_signup_message = BulkSignupMessage.new
    end

    def create
      if @bulk_signup_message.save
        BulkAction::SendBulkSignupMessageJob.perform_later(@bulk_signup_message)
        redirect_to Hub::SignupSelectionsController.to_path_helper(action: :index)
      else
        set_instance_variables(create_params)
        render :new
      end
    end

    private

    def set_instance_variables(params)
      @signup_selection = SignupSelection.accessible_by(current_ability).find(params[:signup_selection_id]) if params[:signup_selection_id].present?
      @message_type =
        case params[:message_type]
        when "email"
          "email"
        when "text_message"
          "text message"
        end

      if @message_type.nil? || @signup_selection.nil?
        redirect_to Hub::SignupSelectionsController.to_path_helper(action: :index)
      else
        @main_heading = "Sending #{@message_type} to #{@signup_selection.id_array.size} signup record(s)"
      end
    end

    def create_params
      params.require(:bulk_signup_message).permit(:signup_selection_id, :message, :message_type).merge(user: current_user)
    end
  end
end

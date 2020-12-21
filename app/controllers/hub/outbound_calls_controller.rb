module Hub
  class OutboundCallsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in, except: :call
    skip_before_action :verify_authenticity_token, only: :call
    load_and_authorize_resource :client, except: :call

    def create
      @form = OutboundCallForm.new(permitted_params, client: @client, user: current_user)
      call = @form.call!
      render :new and return unless call.present?
      
      redirect_to hub_client_outbound_call_path(client_id: @client.id, id: call.id)
    end

    def show; end

    def call
      twiml = Twilio::TwiML::VoiceResponse.new
      twiml.say(message: 'Please wait while we connect your call.')
      twiml.dial(number: params[:phone_number])

      render xml: twiml.to_xml
    end

    def new
      @form = OutboundCallForm.new(client: @client, user: current_user)
    end

    def permitted_params
      params.require(OutboundCallForm.form_param).permit(:user_phone_number, :client_phone_number)
    end
  end
end
module Hub
  class OutboundCallsController < ApplicationController
    include AccessControllable
    before_action :require_sign_in, except: :call
    skip_before_action :verify_authenticity_token, only: :call
    load_and_authorize_resource :client, except: :call

    layout "hub"

    def create
      @form = OutboundCallForm.new(permitted_params, client: @client, user: current_user)
      @form.dial
      render :new and return unless @form.outbound_call&.id
      
      redirect_to hub_client_outbound_call_path(client_id: @client.id, id: @form.outbound_call.id)
    end

    def show
      @outbound_call = OutboundCall.find(params[:id])
      AccessLog.create!(
        user: current_user,
        record: @client,
        event_type: "viewed_call_page_ssn_itin",
        created_at: DateTime.now,
        ip_address: request.remote_ip,
        user_agent: request.user_agent,
      )
    end

    # The form that posts to update is on the show page, and only includes a textarea to update the note.
    def update
      @outbound_call = OutboundCall.find(params[:id])
      @outbound_call.update(params.require(:outbound_call).permit(:note))
      redirect_to hub_client_messages_path(client_id: @client.id, anchor: "last-item")
    end

    def new
      @form = OutboundCallForm.new(client: @client, user: current_user)
    end

    private

    def permitted_params
      params.require(OutboundCallForm.form_param).permit(:user_phone_number, :client_phone_number)
    end
  end
end
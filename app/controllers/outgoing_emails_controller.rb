class OutgoingEmailsController < ApplicationController
  include ZendeskAuthenticationControllerHelper

  before_action :require_zendesk_admin

  def create
    email = OutgoingEmail.new(outgoing_email_params)
    if email.save
      #queue the job
    end
    redirect_to client_path(id: email.client_id)
  end

  private

  def outgoing_email_params
    params.require(:outgoing_email).permit(:client_id, :body).merge(
      subject: "Update from GetYourRefund", sent_at: DateTime.now, user: current_user
    )
  end
end

class OutgoingEmailsController < ApplicationController
  include AccessControllable

  before_action :require_sign_in, :require_beta_tester

  def create
    email = OutgoingEmail.new(outgoing_email_params)
    email.to = email.client.email_address
    if email.save
      OutgoingEmailMailer.user_message(outgoing_email: email).deliver_later
    end
    redirect_to client_messages_path(client_id: email.client_id)
  end

  private

  def outgoing_email_params
    # Use client locale someday
    params.require(:outgoing_email).permit(:client_id, :body).merge(
      subject: I18n.t("email.user_message.subject", locale: "en"),
      sent_at: DateTime.now,
      user: current_user
    )
  end
end

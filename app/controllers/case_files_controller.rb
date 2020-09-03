class CaseFilesController < ApplicationController
  include ZendeskAuthenticationControllerHelper

  before_action :require_zendesk_admin, except: :text_status_callback
  skip_before_action :verify_authenticity_token, only: :create

  layout "admin"

  def create
    intake = Intake.find_by(id: params[:intake_id])
    return head 422 unless intake.present?

    created_case = CaseFile.create_from_intake(intake)
    redirect_to case_file_path(id: created_case.id)
  end

  def show
    @case_file = CaseFile.find(params[:id])
    @contact_history = @case_file.outgoing_text_messages
  end

  def send_text
    outgoing_text_message = OutgoingTextMessage.create(
      case_file: CaseFile.find(params[:case_file_id]),
      body: params[:body],
      sent_at: DateTime.now,
      user: current_user,
    )
    SendOutgoingTextMessageJob.perform_later(outgoing_text_message.id)
    redirect_to case_file_path(id: params[:case_file_id])
  end

  def text_status_callback
    id = ActiveSupport::MessageVerifier.new(EnvironmentCredentials.dig(:secret_key_base)).verified(
      params[:verifiable_outgoing_text_message_id], purpose: :twilio_text_message_status_callback
    )
    return if id.blank?

    OutgoingTextMessage.find(id).update(twilio_status: params[:MessageStatus])
  end
end

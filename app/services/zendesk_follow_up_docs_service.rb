class ZendeskFollowUpDocsService
  include ZendeskServiceHelper
  include AttachmentsHelper
  include Rails.application.routes.url_helpers

  def initialize(intake)
    @intake = intake
    raise "cannot initialize when intake is nil" unless @intake
  end

  def instance
    @intake.zendesk_instance
  end

  def send_requested_docs
    return if @intake.documents.none?

    raise MissingTicketError unless @intake.intake_ticket_id.present?

    new_requested_docs = @intake.documents
                           .where(document_type: "Requested")
                           .or(@intake.documents.where(document_type: "Requested Later"))
                           .where(zendesk_ticket_id: nil)
    ticket_url = zendesk_ticket_url(id: @intake.intake_ticket_id)
    output = append_comment_to_ticket(
      ticket_id: @intake.intake_ticket_id,
      fields: { EitcZendeskInstance::LINK_TO_CLIENT_DOCUMENTS => ticket_url },
      comment: <<~DOCS
        The client added requested follow-up documents:
        #{new_requested_docs.map {|d| "* #{d.upload.filename}\n"}.join }
        View all client documents here:
        #{ticket_url}
      DOCS
    )
    raise CouldNotSendFollowUpDocError unless output
    new_requested_docs.each {|doc| doc.update(zendesk_ticket_id: @intake.intake_ticket_id)}
    DatadogApi.increment("zendesk.ticket.docs.requested.sent")
    output
  end

  class CouldNotSendFollowUpDocError < ZendeskServiceError; end
end

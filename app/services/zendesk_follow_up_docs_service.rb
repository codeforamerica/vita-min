class ZendeskFollowUpDocsService
  include ZendeskServiceHelper
  include AttachmentsHelper
  include ConsolidatedTraceHelper

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
    download_attachments_to_tmp(new_requested_docs.map(&:upload)) do |file_list|

      output = append_multiple_files_to_ticket(
        ticket_id: @intake.intake_ticket_id,
        file_list: file_list,
        comment: "The client added requested follow-up documents:\n" + new_requested_docs.map {|d| "* #{d.upload.filename}\n"}.join,
      )

      raise CouldNotSendFollowUpDocError unless output
      new_requested_docs.each {|doc| doc.update(zendesk_ticket_id: @intake.intake_ticket_id)}
      DatadogApi.increment("zendesk.ticket.docs.requested.sent")
      output
    end
  end

  class CouldNotSendFollowUpDocError < ZendeskServiceError; end
end

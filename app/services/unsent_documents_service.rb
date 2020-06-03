class UnsentDocumentsService
  include ZendeskServiceHelper
  include Rails.application.routes.url_helpers

  def instance
    @instance ||= EitcZendeskInstance
  end

  def detect_unsent_docs_and_notify
    tickets_updated = 0
    Intake.where.not(intake_ticket_id: nil).find_each(batch_size: 100) do |intake|
      unsent_docs = intake.documents.where(zendesk_ticket_id: nil).where("created_at < ?", 15.minutes.ago)
      if unsent_docs.present?
        comment_body = <<~BODY
          New client documents are available to view: #{zendesk_ticket_url(id: intake.intake_ticket_id)}
          Files uploaded:
          #{unsent_docs.map {|d| "* #{d.upload.filename} (#{d.document_type})"}.join("\n")}
        BODY

        append_comment_to_ticket(
          ticket_id: intake.intake_ticket_id,
          comment: comment_body
        )
        unsent_docs.each {|d| d.update(zendesk_ticket_id: intake.intake_ticket_id)}
        tickets_updated += 1
        DatadogApi.gauge("zendesk.ticket.docs.unsent.ticket_updated.document_count", unsent_docs.length)
      end
    end
    DatadogApi.gauge("zendesk.ticket.docs.unsent.tickets_updated", tickets_updated)
    DatadogApi.increment("cronjob.documents.unsent.detect_and_notify")
  end
end
class UnsentDocumentsService
  include ConsolidatedTraceHelper
  include Rails.application.routes.url_helpers

  def detect_unsent_docs_and_notify
    DatadogApi.increment("cronjob.documents.unsent.detect_and_notify")

    tickets_updated = 0
    Intake.where.not(intake_ticket_id: nil).find_each(batch_size: 100) do |intake|
      with_raven_context(intake_context(intake)) do
        unsent_docs = intake.documents.where(zendesk_ticket_id: nil).where("created_at < ?", 15.minutes.ago)
        if unsent_docs.present?
          zendesk_service = ZendeskIntakeService.new(intake)

          ticket = zendesk_service.get_ticket(ticket_id: intake.intake_ticket_id)

          if ticket.present? && ticket.status != "closed"
            comment_body = <<~BODY
              New client documents are available to view: #{zendesk_ticket_url(id: intake.intake_ticket_id)}
              Files uploaded:
              #{unsent_docs.map {|d| "* #{d.upload.filename} (#{d.document_type})"}.join("\n")}
            BODY

            zendesk_service.append_comment_to_ticket(
              ticket_id: intake.intake_ticket_id,
              comment: comment_body
            )
            unsent_docs.each {|d| d.update(zendesk_ticket_id: intake.intake_ticket_id)}
            tickets_updated += 1
            DatadogApi.gauge("zendesk.ticket.docs.unsent.ticket_updated.document_count", unsent_docs.length)
          end
        end
      end
    end
    DatadogApi.gauge("zendesk.ticket.docs.unsent.tickets_updated", tickets_updated)
  end
end

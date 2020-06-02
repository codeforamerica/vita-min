# Backfills document zendesk_ticket_id for documents that have been uploaded to Zendesk. This can be
# removed once it is run once in a production console.
#
# Usage (in rails console):
# > DocumentZendeskTicketIdBackfill.run!
#

class DocumentZendeskTicketIdBackfill
  def self.run!
    Intake.find_each(batch_size: 100) do |intake|
      next unless intake.intake_ticket_id
      print "."

      service = ZendeskIntakeService.new(intake)
      ticket = service.get_ticket(ticket_id: intake.intake_ticket_id)
      next unless ticket

      comments = ticket.comments
      ticket_filenames = comments.map(&:attachments).flatten(1).map(&:file_name)
      next if ticket_filenames.empty?

      intake.documents.each do |doc|
        next if doc.zendesk_ticket_id.present?

        if ticket_filenames.include? doc.upload.filename.to_s
          doc.update(zendesk_ticket_id: intake.intake_ticket_id)
        end
      end
    end
  end
end

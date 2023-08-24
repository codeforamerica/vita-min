class DeleteMoreZendeskColumns < ActiveRecord::Migration[6.0]
  def change
    remove_columns :documents, :zendesk_ticket_id
    remove_columns :intakes,
                   :anonymous, :completed_intake_sent_to_zendesk, :has_enqueued_ticket_creation,
                   :intake_pdf_sent_to_zendesk, :intake_ticket_id, :intake_ticket_requester_id, :primary_intake_id
  end
end

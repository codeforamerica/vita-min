class AddZendeskTicketIdToDocument < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :zendesk_ticket_id, :bigint
  end
end

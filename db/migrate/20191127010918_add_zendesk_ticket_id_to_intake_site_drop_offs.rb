class AddZendeskTicketIdToIntakeSiteDropOffs < ActiveRecord::Migration[5.2]
  def change
    add_column :intake_site_drop_offs, :zendesk_ticket_id, :string
  end
end

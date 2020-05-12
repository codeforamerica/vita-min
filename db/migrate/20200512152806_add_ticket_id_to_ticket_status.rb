class AddTicketIdToTicketStatus < ActiveRecord::Migration[6.0]
  def change
    add_column :ticket_statuses, :ticket_id, :integer
  end
end

class DropTicketStatuses < ActiveRecord::Migration[6.0]
  def change
    drop_table :ticket_statuses
  end
end

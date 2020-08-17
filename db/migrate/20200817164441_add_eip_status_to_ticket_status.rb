class AddEipStatusToTicketStatus < ActiveRecord::Migration[6.0]
  def change
    add_column :ticket_statuses, :eip_status, :string
    change_column :ticket_statuses, :return_status, :string, null: true
    change_column :ticket_statuses, :intake_status, :string, null: true
  end
end

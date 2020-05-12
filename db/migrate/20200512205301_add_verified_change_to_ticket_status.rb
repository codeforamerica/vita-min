class AddVerifiedChangeToTicketStatus < ActiveRecord::Migration[6.0]
  def change
    add_column :ticket_statuses, :verified_change, :boolean, default: true
  end
end

class AddHasEnqueuedTicketCreationToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :has_enqueued_ticket_creation, :boolean, default: false
  end
end

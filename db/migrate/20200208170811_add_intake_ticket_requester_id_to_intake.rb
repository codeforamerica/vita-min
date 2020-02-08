class AddIntakeTicketRequesterIdToIntake < ActiveRecord::Migration[5.2]
  def change
    add_column :intakes, :intake_ticket_requester_id, :integer
  end
end

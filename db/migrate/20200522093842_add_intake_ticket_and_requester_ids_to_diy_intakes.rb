class AddIntakeTicketAndRequesterIdsToDiyIntakes < ActiveRecord::Migration[6.0]
  def change
    add_column :diy_intakes, :ticket_id, :bigint
    add_column :diy_intakes, :requester_id, :bigint
  end
end

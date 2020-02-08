class ChangeZendeskIdsToBigint < ActiveRecord::Migration[5.2]
  def change
    change_column :intakes, :intake_ticket_requester_id, :bigint
    change_column :intakes, :intake_ticket_id, :bigint
  end
end

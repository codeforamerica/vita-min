class AddResponseNeededSinceToClients < ActiveRecord::Migration[6.0]
  def up
    add_column :clients, :response_needed_since, :datetime
    update <<-SQL.squish
      UPDATE clients
      SET response_needed_since = first_unanswered_incoming_interaction_at
    SQL
  end

  def down
    remove_column :clients, :response_needed_since
  end
end

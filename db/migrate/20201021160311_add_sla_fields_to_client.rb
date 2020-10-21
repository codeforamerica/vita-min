class AddSlaFieldsToClient < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :last_interaction_at, :datetime
    add_column :clients, :response_needed_since, :datetime
    rename_column :clients, :last_response_at, :last_incoming_interaction_at
  end
end

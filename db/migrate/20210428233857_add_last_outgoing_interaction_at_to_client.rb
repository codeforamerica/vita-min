class AddLastOutgoingInteractionAtToClient < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :last_outgoing_interaction_at, :datetime, null: true
  end
end

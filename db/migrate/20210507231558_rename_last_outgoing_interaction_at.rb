class RenameLastOutgoingInteractionAt < ActiveRecord::Migration[6.0]
  def change
    rename_column :clients, :last_outgoing_interaction_at, :last_outgoing_communication_at
  end
end

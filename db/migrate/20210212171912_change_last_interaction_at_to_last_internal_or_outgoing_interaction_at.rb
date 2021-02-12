class ChangeLastInteractionAtToLastInternalOrOutgoingInteractionAt < ActiveRecord::Migration[6.0]
  def change
    rename_column :clients, :last_interaction_at, :last_internal_or_outgoing_interaction_at
  end
end

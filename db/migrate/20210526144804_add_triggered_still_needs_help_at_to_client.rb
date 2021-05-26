class AddTriggeredStillNeedsHelpAtToClient < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :triggered_still_needs_help_at, :datetime
  end
end

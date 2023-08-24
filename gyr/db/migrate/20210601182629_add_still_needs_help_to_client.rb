class AddStillNeedsHelpToClient < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :still_needs_help, :integer, default: 0, null: false
  end
end

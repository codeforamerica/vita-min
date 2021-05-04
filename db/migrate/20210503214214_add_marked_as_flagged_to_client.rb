class AddMarkedAsFlaggedToClient < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :marked_as_flagged, :boolean, null: true
  end
end

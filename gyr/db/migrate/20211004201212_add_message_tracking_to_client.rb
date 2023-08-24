class AddMessageTrackingToClient < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :message_tracker, :jsonb, default: {}
  end
end

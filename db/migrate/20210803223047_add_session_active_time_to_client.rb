class AddSessionActiveTimeToClient < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :last_seen_at, :datetime
    add_column :clients, :total_session_active_seconds, :integer
  end
end

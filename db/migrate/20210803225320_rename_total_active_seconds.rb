class RenameTotalActiveSeconds < ActiveRecord::Migration[6.0]
  def change
    rename_column :clients, :total_session_active_seconds, :previous_sessions_active_seconds
  end
end

class ChangeResponseNeededSinceToFlaggedAt < ActiveRecord::Migration[6.0]
  def change
    rename_column :clients, :response_needed_since, :flagged_at
  end
end

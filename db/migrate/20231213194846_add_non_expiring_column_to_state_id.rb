class AddNonExpiringColumnToStateId < ActiveRecord::Migration[7.1]
  def change
    add_column :state_ids, :non_expiring, :boolean, default: false
  end
end

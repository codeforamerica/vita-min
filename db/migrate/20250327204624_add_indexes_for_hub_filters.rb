class AddIndexesForHubFilters < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :vita_partners, :allows_greeters, algorithm: :concurrently
    add_index :intakes, :preferred_name, algorithm: :concurrently
  end
end

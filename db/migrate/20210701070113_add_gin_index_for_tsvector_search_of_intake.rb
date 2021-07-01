class AddGinIndexForTsvectorSearchOfIntake < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :intakes, :searchable_data, using: :gin, algorithm: :concurrently
  end
end

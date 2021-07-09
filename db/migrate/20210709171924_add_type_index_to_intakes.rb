class AddTypeIndexToIntakes < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :intakes, :type, algorithm: :concurrently
  end
end

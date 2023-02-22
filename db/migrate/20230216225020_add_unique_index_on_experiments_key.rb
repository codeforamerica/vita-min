class AddUniqueIndexOnExperimentsKey < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :experiments, :key, unique: true, algorithm: :concurrently
  end
end

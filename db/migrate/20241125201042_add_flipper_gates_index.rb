class AddFlipperGatesIndex < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_index :flipper_gates, [:feature_key, :key, :value], unique: true, length: {value: 255}, algorithm: :concurrently
  end
end

class AddHashedEmailToIntakes < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_column :intakes, :hashed_email, :string
    add_column :diy_intakes, :hashed_email, :string
    add_index :intakes, :hashed_email, algorithm: :concurrently
    add_index :diy_intakes, :hashed_email, algorithm: :concurrently
  end
end

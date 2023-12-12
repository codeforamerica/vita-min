class AddHashedSsnToStateFileIntakes < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_column :state_file_az_intakes, :hashed_ssn, :string
    add_index :state_file_az_intakes, :hashed_ssn, algorithm: :concurrently

    add_column :state_file_ny_intakes, :hashed_ssn, :string
    add_index :state_file_ny_intakes, :hashed_ssn, algorithm: :concurrently
  end
end

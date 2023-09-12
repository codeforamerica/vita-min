class AddSpouseAndDependentHashSsnToIntake < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_column :intakes, :hashed_spouse_ssn, :string
    add_index :intakes, :hashed_spouse_ssn, algorithm: :concurrently

    add_column :dependents, :hashed_ssn, :string
    add_index :dependents, :hashed_ssn, algorithm: :concurrently
  end
end

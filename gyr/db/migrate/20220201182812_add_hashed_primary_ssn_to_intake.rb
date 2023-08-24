class AddHashedPrimarySsnToIntake < ActiveRecord::Migration[6.1]
  def change
    add_column :intakes, :hashed_primary_ssn, :string
    add_index :intakes, :hashed_primary_ssn
  end
end

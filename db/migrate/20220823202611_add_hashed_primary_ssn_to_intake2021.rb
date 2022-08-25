class AddHashedPrimarySsnToIntake2021 < ActiveRecord::Migration[7.0]
  def change
    add_column :archived_intakes_2021, :hashed_primary_ssn, :string
  end
end

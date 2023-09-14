class AddSpouseAndDependentHashSsnToIntake < ActiveRecord::Migration[7.0]

  def change
    add_column :intakes, :hashed_spouse_ssn, :string
    add_column :dependents, :hashed_ssn, :string
  end
end

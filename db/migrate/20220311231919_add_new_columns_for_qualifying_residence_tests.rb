class AddNewColumnsForQualifyingResidenceTests < ActiveRecord::Migration[6.1]
  def change
    add_column :dependents, :residence_lived_with_all_year, :integer, default: 0
    add_column :dependents, :below_qualifying_relative_income_requirement, :integer, default: 0
    add_column :dependents, :filer_provided_over_half_support, :integer, default: 0
  end
end

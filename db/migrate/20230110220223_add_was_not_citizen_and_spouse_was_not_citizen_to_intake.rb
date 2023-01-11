class AddWasNotCitizenAndSpouseWasNotCitizenToIntake < ActiveRecord::Migration[7.0]
  def change
    add_column :dependents, :us_citizen, :integer, default: 0, null: false
  end
end

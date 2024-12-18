class AddHouseholdRentOwnToNjIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nj_intakes, :household_rent_own, :integer, default: 0, null: false
  end
end

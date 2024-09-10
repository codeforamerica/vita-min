class AddEligibilityWithdrew529ToStateFileNcIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nc_intakes, :eligibility_withdrew_529, :integer, default: 0, null: false
  end
end

class AddHomeownerSameHomeEligibilityToNjIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nj_intakes, :homeowner_same_home_spouse, :integer, default: 0, null: false
  end
end

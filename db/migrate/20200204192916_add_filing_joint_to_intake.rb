class AddFilingJointToIntake < ActiveRecord::Migration[5.2]
  def change
    add_column :intakes, :filing_joint, :integer, null: false, default: 0
  end
end

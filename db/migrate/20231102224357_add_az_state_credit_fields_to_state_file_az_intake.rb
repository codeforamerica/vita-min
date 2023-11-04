class AddAzStateCreditFieldsToStateFileAzIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :tribal_member, :integer, default: 0, null: false
    add_column :state_file_az_intakes, :tribal_wages, :integer
    add_column :state_file_az_intakes, :armed_forces_member, :integer, default: 0, null: false
    add_column :state_file_az_intakes, :armed_forces_wages, :integer
  end
end

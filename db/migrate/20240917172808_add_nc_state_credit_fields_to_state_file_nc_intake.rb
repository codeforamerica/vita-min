class AddNcStateCreditFieldsToStateFileNcIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nc_intakes, :tribal_member, :integer, default: 0, null: false
    add_column :state_file_nc_intakes, :tribal_wages, :decimal, precision: 12, scale: 2
  end
end

class AddNycResidencyColumnsToStateFileNyIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_ny_intakes, :nyc_residency, :integer, default: 0, null: false
    add_column :state_file_ny_intakes, :nyc_maintained_home, :integer, default: 0, null: false
  end
end

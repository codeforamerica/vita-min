class AddRawDirectFileDataToStateIntakes < ActiveRecord::Migration[7.0]
  def change
    add_column :state_file_az_intakes, :raw_direct_file_data, :text
    add_column :state_file_ny_intakes, :raw_direct_file_data, :text
  end
end

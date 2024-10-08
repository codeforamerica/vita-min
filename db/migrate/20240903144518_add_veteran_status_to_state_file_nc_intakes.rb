class AddVeteranStatusToStateFileNcIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nc_intakes, :primary_veteran, :integer, default: 0, null: false
    add_column :state_file_nc_intakes, :spouse_veteran, :integer, default: 0, null: false
  end
end

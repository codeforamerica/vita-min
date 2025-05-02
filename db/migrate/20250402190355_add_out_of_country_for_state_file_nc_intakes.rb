class AddOutOfCountryForStateFileNcIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nc_intakes, :out_of_country, :integer, default: 0, null: false
  end
end

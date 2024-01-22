class RemoveNycFullYearResidentFromStateFileNyIntakes < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :state_file_ny_intakes, :nyc_full_year_resident, :integer, default: 0, null: false }
  end
end

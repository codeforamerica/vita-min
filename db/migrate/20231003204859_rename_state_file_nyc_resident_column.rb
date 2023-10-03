class RenameStateFileNycResidentColumn < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      rename_column :state_file_ny_intakes, :nyc_resident_e, :nyc_full_year_resident
    end
  end
end

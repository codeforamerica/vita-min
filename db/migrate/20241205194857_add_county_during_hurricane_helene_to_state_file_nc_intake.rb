class AddCountyDuringHurricaneHeleneToStateFileNcIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nc_intakes, :county_during_hurricane_helene, :string, null: true, default: nil
    add_column :state_file_nc_intakes, :moved_after_hurricane_helene, :integer, default: 0, null: false
  end
end

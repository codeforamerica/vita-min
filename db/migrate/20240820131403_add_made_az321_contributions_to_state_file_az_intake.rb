class AddMadeAz321ContributionsToStateFileAzIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :made_az321_contributions, :integer, default: 0, null: false
  end
end

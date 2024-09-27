class MoveMadeAz322ContributionsToIntake < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :az322_contributions, :made_contribution, :integer, default: 0, null: false }
    add_column :state_file_az_intakes, :made_az322_contributions, :integer, default: 0, null: false
  end
end

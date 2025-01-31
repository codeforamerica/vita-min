class AddSchoolContributionsToStateFileAzIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :school_contributions, :integer, default: 0, null: false
  end
end

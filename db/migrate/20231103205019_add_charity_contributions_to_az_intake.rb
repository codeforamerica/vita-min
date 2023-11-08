class AddCharityContributionsToAzIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :charitable_contributions, :integer, default: 0, null: false
  end
end

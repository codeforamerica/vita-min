class AddWasIncarceratedToStateFileAzIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :was_incarcerated, :integer, default: 0, null: false
  end
end

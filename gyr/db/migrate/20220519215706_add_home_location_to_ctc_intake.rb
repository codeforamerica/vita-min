class AddHomeLocationToCtcIntake < ActiveRecord::Migration[7.0]
  def change
    add_column :intakes, :home_location, :integer
  end
end

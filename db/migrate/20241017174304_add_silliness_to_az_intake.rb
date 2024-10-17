class AddSillinessToAzIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :silliness, :boolean
  end
end

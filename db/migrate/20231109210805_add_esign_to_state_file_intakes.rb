class AddEsignToStateFileIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_ny_intakes, :esigned_return, :integer, default: 0, null: false
    add_column :state_file_ny_intakes, :esigned_return_at, :datetime
    add_column :state_file_az_intakes, :esigned_return, :integer, default: 0, null: false
    add_column :state_file_az_intakes, :esigned_return_at, :datetime
  end
end

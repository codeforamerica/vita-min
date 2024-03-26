class AddLastCompletedStep < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :last_completed_step, :string
    add_column :state_file_ny_intakes, :last_completed_step, :string
  end
end

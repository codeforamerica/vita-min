class AddDeviseToStateFileIntakes < ActiveRecord::Migration[7.1]
  def change
    # trackable
    add_column :state_file_az_intakes, :sign_in_count, :integer, default: 0, null: false
    add_column :state_file_ny_intakes, :sign_in_count, :integer, default: 0, null: false
    add_column :state_file_az_intakes, :current_sign_in_at, :datetime
    add_column :state_file_ny_intakes, :current_sign_in_at, :datetime
    add_column :state_file_az_intakes, :last_sign_in_at, :datetime
    add_column :state_file_ny_intakes, :last_sign_in_at, :datetime
    add_column :state_file_az_intakes, :last_sign_in_ip, :inet
    add_column :state_file_ny_intakes, :last_sign_in_ip, :inet
    add_column :state_file_az_intakes, :current_sign_in_ip, :inet
    add_column :state_file_ny_intakes, :current_sign_in_ip, :inet

    # lockable
    add_column :state_file_az_intakes, :failed_attempts, :integer, default: 0, null: false
    add_column :state_file_ny_intakes, :failed_attempts, :integer, default: 0, null: false
    add_column :state_file_az_intakes, :locked_at, :datetime
    add_column :state_file_ny_intakes, :locked_at, :datetime
  end
end

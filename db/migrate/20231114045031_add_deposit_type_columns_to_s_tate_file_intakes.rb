class AddDepositTypeColumnsToSTateFileIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :deposit_type, :integer, default: 0, null: false
    add_column :state_file_ny_intakes, :deposit_type, :integer, default: 0, null: false
  end
end

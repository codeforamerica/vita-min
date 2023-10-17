class AddBankFieldsToAzIntake < ActiveRecord::Migration[7.0]
  def change
    add_column :state_file_az_intakes, :bank_routing_number, :string
    add_column :state_file_az_intakes, :bank_account_number, :string
    add_column :state_file_az_intakes, :bank_account_type, :integer
  end
end
class AddBankFieldsToStateFileNcIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nc_intakes, :date_electronic_withdrawal, :date
    add_column :state_file_nc_intakes, :account_number, :string
    add_column :state_file_nc_intakes, :routing_number, :integer
    add_column :state_file_nc_intakes, :bank_name, :string
    add_column :state_file_nc_intakes, :withdraw_amount, :integer
  end
end

class AddBankInfoToIntake < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :encrypted_bank_name, :string
    add_column :intakes, :encrypted_bank_routing_number, :string
    add_column :intakes, :encrypted_bank_account_number, :string
    add_column :intakes, :bank_account_type, :integer, default: 0, null: false
  end
end

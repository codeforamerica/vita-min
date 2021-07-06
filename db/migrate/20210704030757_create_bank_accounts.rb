class CreateBankAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :bank_accounts do |t|
      t.timestamps
      t.string :encrypted_account_number
      t.string :encrypted_account_number_iv
      t.string :encrypted_routing_number
      t.string :encrypted_routing_number_iv
      t.string :encrypted_bank_name
      t.string :encrypted_bank_name_iv
      t.integer :account_type
      t.references :intake
    end
    add_reference :intakes, :bank_account
  end
end

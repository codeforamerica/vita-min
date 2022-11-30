class Archive2022BankAccounts < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      rename_table :bank_accounts, :archived_bank_accounts_2022
      rename_column :archived_bank_accounts_2022, :intake_id, :archived_intakes_2022_id
    end
  end
end

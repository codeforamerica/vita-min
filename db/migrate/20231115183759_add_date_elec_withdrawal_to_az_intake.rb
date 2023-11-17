class AddDateElecWithdrawalToAzIntake < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      add_column :state_file_az_intakes, :payment_or_deposit_type, :integer, default: 0, null: false
      add_column :state_file_ny_intakes, :payment_or_deposit_type, :integer, default: 0, null: false
      add_column :state_file_az_intakes, :date_electronic_withdrawal, :date
      rename_column :state_file_az_intakes, :bank_account_number, :account_number
      rename_column :state_file_az_intakes, :bank_account_type, :account_type
      rename_column :state_file_az_intakes, :bank_routing_number, :routing_number
      add_column :state_file_az_intakes, :bank_name, :string
      add_column :state_file_ny_intakes, :bank_name, :string
      add_column :state_file_az_intakes, :withdraw_amount, :integer
      add_column :state_file_ny_intakes, :withdraw_amount, :integer
      remove_column :state_file_ny_intakes, :refund_choice, :integer
      remove_column :state_file_ny_intakes, :amount_electronic_withdrawal, :integer
      remove_column :state_file_ny_intakes, :amount_owed_pay_electronically, :integer
    end
  end
end

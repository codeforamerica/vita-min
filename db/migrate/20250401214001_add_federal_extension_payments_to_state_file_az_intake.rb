class AddFederalExtensionPaymentsToStateFileAzIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :federal_extension_payments_amount, :decimal, default: 0, precision: 12, scale: 2
    add_column :state_file_az_intakes, :paid_federal_extension_payments, :integer, default: 0, null: false
  end
end

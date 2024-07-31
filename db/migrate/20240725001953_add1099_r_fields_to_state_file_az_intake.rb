class Add1099RFieldsToStateFileAzIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :received_military_retirement_payment, :integer, default: 0, null: false
    add_column :state_file_az_intakes, :primary_received_pension, :integer, default: 0, null: false
    add_column :state_file_az_intakes, :spouse_received_pension, :integer, default: 0, null: false

    add_column :state_file_az_intakes, :received_military_retirement_payment_amount, :decimal, precision: 12, scale: 2
    add_column :state_file_az_intakes, :primary_received_pension_amount, :decimal, precision: 12, scale: 2
    add_column :state_file_az_intakes, :spouse_received_pension_amount, :decimal, precision: 12, scale: 2
  end
end

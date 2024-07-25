class Add1099RFieldsToStateFileAzIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_az_intakes, :form1099r_received_military_payment, :integer, default: 0, null: false
    add_column :state_file_az_intakes, :form1099r_primary_received_pension, :integer, default: 0, null: false
    add_column :state_file_az_intakes, :form1099r_spouse_received_pension, :integer, default: 0, null: false

    add_column :state_file_az_intakes, :form1099r_received_military_payment_amount, :decimal, precision: 12, scale: 2
    add_column :state_file_az_intakes, :form1099r_primary_received_pension_amount, :decimal, precision: 12, scale: 2
    add_column :state_file_az_intakes, :form1099r_spouse_received_pension_amount, :decimal, precision: 12, scale: 2
  end
end

class Remove1099RAggregateFieldsFromAzIntake < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      remove_column :state_file_az_intakes, :received_military_retirement_payment
      remove_column :state_file_az_intakes, :primary_received_pension
      remove_column :state_file_az_intakes, :spouse_received_pension

      remove_column :state_file_az_intakes, :received_military_retirement_payment_amount
      remove_column :state_file_az_intakes, :primary_received_pension_amount
      remove_column :state_file_az_intakes, :spouse_received_pension_amount
    end
  end
end

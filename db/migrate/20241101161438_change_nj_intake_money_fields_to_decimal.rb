class ChangeNjIntakeMoneyFieldsToDecimal < ActiveRecord::Migration[7.1]
  def change
    safety_assured {
      change_column :state_file_nj_intakes, :sales_use_tax, :decimal, precision: 12, scale: 2
      change_column :state_file_nj_intakes, :property_tax_paid, :decimal, precision: 12, scale: 2
      change_column :state_file_nj_intakes, :rent_paid, :decimal, precision: 12, scale: 2
      change_column :state_file_nj_intakes, :medical_expenses, :decimal, precision: 12, scale: 2
    }
  end
end

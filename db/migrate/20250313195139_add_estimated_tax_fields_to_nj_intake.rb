class AddEstimatedTaxFieldsToNjIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nj_intakes, :has_estimated_payments, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :overpayments, :decimal, precision: 12, scale: 2
  end
end

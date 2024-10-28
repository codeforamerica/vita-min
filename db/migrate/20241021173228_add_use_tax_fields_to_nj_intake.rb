class AddUseTaxFieldsToNjIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nj_intakes, :untaxed_out_of_state_purchases, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :sales_use_tax_calculation_method, :integer, default: 0, null: false
    add_column :state_file_nj_intakes, :sales_use_tax, :integer
  end
end

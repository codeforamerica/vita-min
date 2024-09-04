class AddUseTaxFieldsToNcIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nc_intakes, :sales_use_tax, :integer
    add_column :state_file_nc_intakes, :sales_use_tax_calculation_method, :integer, default: 0, null: false
  end
end

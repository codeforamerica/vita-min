class RenameTaxWithheldFieldOnStateIntakes < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      rename_column :state_file_ny_intakes, :total_ny_tax_withheld, :total_state_tax_withheld
      rename_column :state_file_az_intakes, :total_ny_tax_withheld, :total_state_tax_withheld
      remove_column :state_file_ny_intakes, :ny_taxable_ssb
    end
  end
end

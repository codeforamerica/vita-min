class RemoveTaxReturnYearFromStateFileIntakes < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      remove_column :state_file_md_intakes, :tax_return_year
      remove_column :state_file_nj_intakes, :tax_return_year
      remove_column :state_file_nc_intakes, :tax_return_year
    end
  end
end

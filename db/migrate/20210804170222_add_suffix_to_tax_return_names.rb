class AddSuffixToTaxReturnNames < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :primary_suffix, :string
    add_column :intakes, :spouse_suffix, :string
    add_column :dependents, :suffix, :string
  end
end

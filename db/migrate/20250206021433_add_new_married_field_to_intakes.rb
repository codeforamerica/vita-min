class AddNewMarriedFieldToIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :intakes, :married_for_all_of_tax_year, :integer, default: 0, null: false
  end
end

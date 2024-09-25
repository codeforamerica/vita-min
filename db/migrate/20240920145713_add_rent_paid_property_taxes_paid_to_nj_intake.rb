class AddRentPaidPropertyTaxesPaidToNjIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_nj_intakes, :property_tax_paid, :integer
    add_column :state_file_nj_intakes, :rent_paid, :integer
  end
end

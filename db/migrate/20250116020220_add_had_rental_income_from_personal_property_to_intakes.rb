class AddHadRentalIncomeFromPersonalPropertyToIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :intakes, :had_rental_income_from_personal_property, :integer, default: 0, null: false
  end
end

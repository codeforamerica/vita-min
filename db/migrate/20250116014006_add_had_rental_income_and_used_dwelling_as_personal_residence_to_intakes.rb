class AddHadRentalIncomeAndUsedDwellingAsPersonalResidenceToIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :intakes, :had_rental_income_and_used_dwelling_as_residence, :integer, default: 0, null: false
  end
end

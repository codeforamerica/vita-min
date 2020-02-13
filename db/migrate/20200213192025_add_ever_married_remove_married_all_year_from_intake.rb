class AddEverMarriedRemoveMarriedAllYearFromIntake < ActiveRecord::Migration[5.2]
  def change
    add_column :intakes, :ever_married, :integer, default: 0, null: false
    remove_column :intakes, :married_all_year, :integer
  end
end

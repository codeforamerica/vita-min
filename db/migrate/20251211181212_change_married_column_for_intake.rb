class ChangeMarriedColumnForIntake < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :intakes, :married_for_all_of_tax_year, :integer }
    add_column :intakes, :married_last_day_of_year, :integer, default: 0, null: false
  end
end

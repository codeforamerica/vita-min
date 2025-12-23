class ChangeMarriedColumnForIntake < ActiveRecord::Migration[7.1]
  def change
    add_column :intakes, :married_last_day_of_year, :integer, default: 0, null: false
  end
end

class AddLivedApartFromSpouseLast6MonthsToIntakes < ActiveRecord::Migration[7.1]
  def change
    add_column :intakes, :lived_apart_from_spouse_last_6_months, :integer, default: 0, null: false
  end
end

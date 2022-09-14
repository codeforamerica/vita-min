class AddNonW2IncomeFieldsToIntakes < ActiveRecord::Migration[7.0]
  def change
    add_column :intakes, :had_non_w2_income, :integer
    add_column :intakes, :non_w2_income_amount, :integer
  end
end

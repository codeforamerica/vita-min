class AddNonW2IncomeFieldsToIntakes < ActiveRecord::Migration[7.0]
  def change
    add_column :intakes, :had_disqualifying_non_w2_income, :integer
  end
end

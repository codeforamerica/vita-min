class HadReportableIncome < ActiveRecord::Migration[6.0]
  def change
    add_column :intakes, :had_reportable_income, :integer
  end
end

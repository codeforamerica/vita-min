class AddInvestmentIncomeLimitToIntake < ActiveRecord::Migration[7.0]
  def change
    add_column :intakes, :exceeded_investment_income_limit, :integer, default: 0
  end
end

class AddHasCryptoIncomeToIntakes < ActiveRecord::Migration[6.1]
  def change
    add_column :intakes, :has_crypto_income, :boolean, default: false
  end
end

class DropStatusFromTaxReturns < ActiveRecord::Migration[7.0]
  def change
    safety_assured do
      remove_column :tax_returns, :status, :integer, default: 100, null: false
    end
  end
end

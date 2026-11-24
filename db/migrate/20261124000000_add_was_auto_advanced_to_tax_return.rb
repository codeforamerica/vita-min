class AddWasAutoAdvancedToTaxReturn < ActiveRecord::Migration[8.1]
  def change
    add_column :tax_returns, :was_auto_advanced, :boolean, default: false, null: true
  end
end

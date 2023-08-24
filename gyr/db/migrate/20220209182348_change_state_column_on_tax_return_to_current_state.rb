class ChangeStateColumnOnTaxReturnToCurrentState < ActiveRecord::Migration[6.1]
  def change
    rename_column :tax_returns, :state, :current_state
  end
end

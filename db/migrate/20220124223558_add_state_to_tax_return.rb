class AddStateToTaxReturn < ActiveRecord::Migration[6.1]
  def change
    add_column :tax_returns, :state, :string
    add_index :tax_returns, :state
  end
end

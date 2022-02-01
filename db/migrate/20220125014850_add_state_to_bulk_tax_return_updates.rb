class AddStateToBulkTaxReturnUpdates < ActiveRecord::Migration[6.1]
  def change
    add_column :bulk_tax_return_updates, :state, :string
    add_index :bulk_tax_return_updates, :state
  end
end

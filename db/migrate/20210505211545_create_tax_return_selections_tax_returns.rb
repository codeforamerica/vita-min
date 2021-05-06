class CreateTaxReturnSelectionsTaxReturns < ActiveRecord::Migration[6.0]
  def change
    create_table :tax_return_selection_tax_returns do |t|
      t.timestamps
      t.references :tax_return_selection, null: false, foreign_key: true, index: { name: :index_trstr_on_tax_return_selection_id }
      t.references :tax_return, null: false, foreign_key: true, index: { name: :index_trstr_on_tax_return_id }
    end
  end
end

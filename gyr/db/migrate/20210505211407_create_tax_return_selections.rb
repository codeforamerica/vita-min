class CreateTaxReturnSelections < ActiveRecord::Migration[6.0]
  def change
    create_table :tax_return_selections do |t|
      t.timestamps
    end
  end
end

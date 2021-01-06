class AddTaxReturnToDocument < ActiveRecord::Migration[6.0]
  def change
    add_reference :documents, :tax_return, null: true, foreign_key: true
  end
end

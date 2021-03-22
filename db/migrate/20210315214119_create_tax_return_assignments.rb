class CreateTaxReturnAssignments < ActiveRecord::Migration[6.0]
  def change
    create_table :tax_return_assignments do |t|
      t.references :tax_return, null: false, foreign_key: true
      t.references :assigner, index: true, foreign_key: { to_table: :users }
      t.timestamps
    end
  end
end

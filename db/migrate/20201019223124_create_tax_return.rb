class CreateTaxReturn < ActiveRecord::Migration[6.0]
  def change
    create_table :tax_returns do |t|
      t.integer :year, null: false
      t.references :client, null: false, foreign_key: true
      t.references :assigned_user, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :tax_returns, [:year, :client_id], unique: true
  end
end

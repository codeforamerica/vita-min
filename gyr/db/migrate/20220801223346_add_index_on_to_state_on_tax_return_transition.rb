class AddIndexOnToStateOnTaxReturnTransition < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :tax_return_transitions, [:to_state, :created_at], algorithm: :concurrently
  end
end

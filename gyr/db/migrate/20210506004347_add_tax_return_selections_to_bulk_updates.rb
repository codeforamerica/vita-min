class AddTaxReturnSelectionsToBulkUpdates < ActiveRecord::Migration[6.0]
  def change
    add_reference :bulk_client_organization_updates, :tax_return_selection, foreign_key: true, index: { name: :index_bcou_on_tax_return_selection_id }
    add_reference :bulk_client_notes, :tax_return_selection, foreign_key: true, index: { name: :index_bcn_on_tax_return_selection_id }
    add_reference :bulk_client_messages, :tax_return_selection, foreign_key: true, index: { name: :index_bcm_on_tax_return_selection_id }

    change_column_null :bulk_client_organization_updates, :client_selection_id, true
    change_column_null :bulk_client_notes, :client_selection_id, true
    change_column_null :bulk_client_messages, :client_selection_id, true
  end
end

class CreateBulkTaxReturnAssigneeAndStatusUpdate < ActiveRecord::Migration[6.0]
  def change
    create_table :bulk_tax_return_assignee_and_status_updates do |t|
      t.timestamps
      t.references :tax_return_selection, null: false, foreign_key: true, index: { name: :index_btraasu_on_tax_return_selection_id }
      t.references :assigned_user, null: true, foreign_key: { to_table: :users }, index: { name: :index_btraasu_on_assigned_user_id }
      t.integer :status
    end
  end
end

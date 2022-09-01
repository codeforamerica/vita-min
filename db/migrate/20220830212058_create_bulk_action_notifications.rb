class CreateBulkActionNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :bulk_action_notifications do |t|
      t.string :task_type, null: false
      t.references :tax_return_selection, null: false, foreign_key: true

      t.timestamps
    end
  end
end

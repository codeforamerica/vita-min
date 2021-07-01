class AddIndexForSearchFlushTimestampOnIntake < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index(
      :intakes,
      :needs_to_flush_searchable_data_set_at,
      where: "needs_to_flush_searchable_data_set_at IS NOT NULL",
      algorithm: :concurrently
    )
  end
end

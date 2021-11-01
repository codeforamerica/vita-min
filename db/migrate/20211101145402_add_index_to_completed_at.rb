class AddIndexToCompletedAt < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index(
        :intakes,
        :completed_at,
        where: "completed_at IS NOT NULL",
        algorithm: :concurrently
    )
  end
end

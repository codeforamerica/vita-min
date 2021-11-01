class AddIndexOnEfileSubmissionTransitionsCreatedAt < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index(
      :efile_submission_transitions,
      :created_at,
      algorithm: :concurrently
    )
  end
end

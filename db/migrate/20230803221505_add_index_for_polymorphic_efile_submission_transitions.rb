class AddIndexForPolymorphicEfileSubmissionTransitions < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index(
      :efile_submission_transitions,
      [:efile_submission_type, :efile_submission_id],
      name: "index_efile_sub_transitions_on_efile_sub_type_and_efile_sub_id",
      algorithm: :concurrently
    )
  end
end

class CreateEfileSubmissionTransitions < ActiveRecord::Migration[6.0]
  def change
    create_table :efile_submission_transitions do |t|
      t.string :to_state, null: false
      t.jsonb :metadata, default: {}
      t.integer :sort_key, null: false
      t.integer :efile_submission_id, null: false
      t.boolean :most_recent, null: false

      # If you decide not to include an updated timestamp column in your transition
      # table, you'll need to configure the `updated_timestamp_column` setting in your
      # migration class.
      t.timestamps null: false
    end

    # Foreign keys are optional, but highly recommended
    add_foreign_key :efile_submission_transitions, :efile_submissions

    add_index(:efile_submission_transitions,
              %i(efile_submission_id sort_key),
              unique: true,
              name: "index_efile_submission_transitions_parent_sort")
    add_index(:efile_submission_transitions,
              %i(efile_submission_id most_recent),
              unique: true,
              where: "most_recent",
              name: "index_efile_submission_transitions_parent_most_recent")
  end
end

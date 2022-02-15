class CreateVerificationAttemptTransitions < ActiveRecord::Migration[6.1]
  def change
    create_table :verification_attempt_transitions do |t|
      t.string :to_state, null: false
      t.jsonb :metadata, default: {}
      t.integer :sort_key, null: false
      t.integer :verification_attempt_id, null: false
      t.boolean :most_recent, null: false
      t.timestamps null: false
    end

    # Foreign keys are optional, but highly recommended
    add_foreign_key :verification_attempt_transitions, :verification_attempts

    add_index(:verification_attempt_transitions,
              %i(verification_attempt_id sort_key),
              unique: true,
              name: "index_verification_attempt_transitions_parent_sort")
    add_index(:verification_attempt_transitions,
              %i(verification_attempt_id most_recent),
              unique: true,
              where: "most_recent",
              name: "index_verification_attempt_transitions_parent_most_recent")
  end
end

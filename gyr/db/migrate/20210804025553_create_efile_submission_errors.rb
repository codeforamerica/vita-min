class CreateEfileSubmissionErrors < ActiveRecord::Migration[6.0]
  def change
    create_table :efile_submission_transition_errors do |t|
      t.timestamps
      t.references :efile_submission
      t.references :efile_error
      t.references :efile_submission_transition, index: { name: 'index_este_on_esti' }
    end
  end
end

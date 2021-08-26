class AddDependentToEfileSubmissionTransitionErrors < ActiveRecord::Migration[6.0]
  def change
    add_reference :efile_submission_transition_errors, :dependent
  end
end

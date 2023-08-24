class AddQualifyingEitcToSubmissionDependents < ActiveRecord::Migration[7.0]
  def change
    add_column :efile_submission_dependents, :qualifying_eitc, :boolean
  end
end

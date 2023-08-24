class AddCreatedAtIndexToEfileSubmission < ActiveRecord::Migration[6.0]
  def change
    add_index :efile_submissions, :created_at
  end
end

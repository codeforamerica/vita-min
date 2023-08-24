class RemoveVerificationAttemptNotesTable < ActiveRecord::Migration[6.1]
  def up
    drop_table :verification_attempt_notes
  end
end

class CreateVerificationAttemptNotes < ActiveRecord::Migration[6.1]
  def change
    create_table :verification_attempt_notes do |t|
      t.references :verification_attempt
      t.references :user
      t.text :body
      t.timestamps
    end
  end
end

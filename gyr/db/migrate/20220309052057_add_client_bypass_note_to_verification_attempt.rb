class AddClientBypassNoteToVerificationAttempt < ActiveRecord::Migration[6.1]
  def change
    add_column :verification_attempts, :client_bypass_request, :text
  end
end

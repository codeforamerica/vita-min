class CreateVerificationAttempts < ActiveRecord::Migration[6.1]
  def change
    create_table :verification_attempts do |t|

      t.timestamps
    end
  end
end

# I don't think I can add this manually can I? if I do then maybe I need to run db:migrate command to capture these changes
# t.references :client
# t.text :note_body
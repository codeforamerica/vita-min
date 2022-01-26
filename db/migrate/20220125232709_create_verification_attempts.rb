class CreateVerificationAttempts < ActiveRecord::Migration[6.1]
  def change
    create_table :verification_attempts do |t|
      t.references :client
      t.text :note_body
      
      t.timestamps
    end
  end
end

